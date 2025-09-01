function New-PSMsSPOUploadPayload {
    <#
    .SYNOPSIS
        Builds a Microsoft Graph PUT upload payload (headers + body) from a file or raw bytes.

    .DESCRIPTION
        Produces a normalized payload for small PUT uploads (<= 4 MB):
          - Headers: hashtable with 'Content-Type' and optional 'If-Match'
          - Body   : string in text mode or [byte[]] in binary mode
          - IsText : boolean indicating selected mode
          - DetectedEncoding : encoding used when IsText is $true, otherwise $null
          - ContentLength    : byte length of the body

        Mode selection:
          - If -AsText is specified → text mode.
          - If -AsBinary is specified → binary mode.
          - Otherwise the function tries strict UTF-8 decode (no replacement),
            rejects content with NUL characters, and permits only a small fraction
            of control characters; if it passes, text mode is used.
          - Additionally, ZIP magic signatures (PK 03 04 / 05 06 / 07 08) force
            binary mode to avoid accidental text handling of archives.

        Use this payload directly with Invoke-EntraRequest (PUT) or wrap it with
        Invoke-PSMsSPOSmallUpload.

    .PARAMETER FilePath
        Local file path. The file is read entirely into memory.

    .PARAMETER Bytes
        Raw content to evaluate. Provide either -FilePath or -Bytes.

    .PARAMETER AsText
        Forces text mode, bypassing autodetection.

    .PARAMETER AsBinary
        Forces binary mode, bypassing autodetection.

    .PARAMETER Encoding
        Encoding used in text mode when converting bytes to string. Default: UTF-8.

    .PARAMETER ContentType
        Overrides Content-Type header. Defaults:
          - text mode   → 'text/plain; charset=<Encoding.WebName>'
          - binary mode → 'application/octet-stream' (or 'application/zip' for ZIP magic)

    .PARAMETER ETag
        Optional If-Match header value for optimistic concurrency.

    .OUTPUTS
        System.Collections.Hashtable
        Keys: Headers, Body, IsText, DetectedEncoding, ContentLength

    .EXAMPLE
        PS> $payload = New-PSMsSPOUploadPayload -FilePath 'C:\Temp\notes.txt'
        PS> Invoke-EntraRequest -Service $service -Path $put -Method Put -Header $payload.Headers -Body $payload.Body -NoJson
        Builds a text payload and uploads it via PUT.

    .EXAMPLE
        PS> $bytes = [IO.File]::ReadAllBytes('C:\Temp\archive.zip')
        PS> $payload = New-PSMsSPOUploadPayload -Bytes $bytes -AsBinary -ContentType 'application/zip'
        PS> Invoke-EntraRequest -Service $service -Path $put -Method Put -Header $payload.Headers -Body $payload.Body -NoJson
        Builds a binary payload for a ZIP archive and uploads it via PUT.

    .NOTES
        Keep this function internal (do not export). It focuses on small PUT uploads.
        For large transfers, create an upload session and use Invoke-PSMsSPOChunkedUpload.
    #>
    [CmdletBinding(DefaultParameterSetName='ByFile')]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory, ParameterSetName='ByFile')]
        [ValidateFileExistsAttribute()]
        [string] $FilePath,
        [Parameter(Mandatory, ParameterSetName='ByBytes')]
        [byte[]] $Bytes,
        [Parameter()]
         [switch] $AsText,
        [Parameter()]
        [switch] $AsBinary,
        [Parameter()] 
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8,
        [Parameter()] 
        [string] $ContentType,
        [Parameter()] 
        [string] $ETag
    )

    begin {
        $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true) # throwOnInvalidBytes
        function Test-IsUtf8Text([byte[]]$Data, [System.Text.UTF8Encoding]$StrictEnc) {
            try {
                $s = $StrictEnc.GetString($Data)
                if ($s.IndexOf([char]0) -ge 0) { return $false } # NUL char → binary
                $ctrl = 0
                foreach ($ch in $s.ToCharArray()) {
                    $code = [int]$ch
                    if ($code -lt 32 -and $ch -ne "`r" -and $ch -ne "`n" -and $ch -ne "`t") { $ctrl++ }
                }
                return ($ctrl -le [Math]::Max(3, [Math]::Ceiling([double]$s.Length * 0.01)))
            } catch { return $false }
        }
        function Test-IsZip([byte[]]$Data) {
            if ($Data.Length -lt 4) { return $false }
            # ZIP signatures: 50 4B 03 04 | 50 4B 05 06 | 50 4B 07 08
            return ($Data[0] -eq 0x50 -and $Data[1] -eq 0x4B -and ($Data[2] -in 0x03,0x05,0x07) -and ($Data[3] -in 0x04,0x06,0x08))
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByFile') {
            $Bytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $FilePath).Path)
        }

        $headers = @{}
        if ($ETag) { $headers['If-Match'] = $ETag }

        # Force binary for ZIP magic signatures
        if (-not $AsText -and (Test-IsZip -Data $Bytes)) {
            if (-not $ContentType) { $ContentType = 'application/zip' }
            $headers['Content-Type'] = $ContentType
            return @{
                Headers          = $headers
                Body             = $Bytes
                IsText           = $false
                DetectedEncoding = $null
                ContentLength    = $Bytes.LongLength
            }
        }

        $isText =
            if     ($AsBinary) { $false }
            elseif ($AsText)   { $true  }
            else               { Test-IsUtf8Text -Data $Bytes -StrictEnc $utf8Strict }

        if ($isText) {
            $text = $Encoding.GetString($Bytes)
            if (-not $ContentType) { $ContentType = 'text/plain; charset=' + $Encoding.WebName }
            $headers['Content-Type'] = $ContentType
            return @{
                Headers          = $headers
                Body             = $text
                IsText           = $true
                DetectedEncoding = $Encoding
                ContentLength    = $Encoding.GetByteCount($text)
            }
        }
        else {
            if (-not $ContentType) { $ContentType = 'application/octet-stream' }
            $headers['Content-Type'] = $ContentType
            return @{
                Headers          = $headers
                Body             = $Bytes
                IsText           = $false
                DetectedEncoding = $null
                ContentLength    = $Bytes.LongLength
            }
        }
    }
}
