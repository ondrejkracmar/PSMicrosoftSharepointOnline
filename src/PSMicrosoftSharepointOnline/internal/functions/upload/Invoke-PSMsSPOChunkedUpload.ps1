function Invoke-PSMsSPOChunkedUpload {
    <#
    .SYNOPSIS
        Uploads a file to a Microsoft Graph upload session in chunks.

    .DESCRIPTION
        Repeatedly PUTs byte ranges to the absolute uploadUrl using Content-Range/Length.
        The final PUT returns the resulting driveItem.

    .PARAMETER Service
        Entra service name for Invoke-EntraRequest.

    .PARAMETER UploadUrl
        Absolute upload session URL from createUploadSession.

    .PARAMETER Content
        Whole file as byte[].

    .PARAMETER ChunkSizeMB
        1..256 MB, default 8 MB.

    .OUTPUTS
        Microsoft Graph driveItem (final response).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Service,
        [Parameter(Mandatory)]
        [string] $UploadUrl,
        [Parameter(Mandatory)]
        [byte[]] $Content,
        [ValidateRange(1,256)]
        [int] $ChunkSizeMB = 8
    )
    $chunk = $ChunkSizeMB * 1MB
    [long]$total = $Content.LongLength
    [long]$pos = 0
    while ($pos -lt $total) {
        $len = [Math]::Min($chunk, $total - $pos)
        $rangeEnd = $pos + $len - 1
        $headers = @{
            'Content-Length' = $len
            'Content-Range'  = ("bytes {0}-{1}/{2}" -f $pos, $rangeEnd, $total)
        }
        $slice = New-Object byte[] $len
        [Array]::Copy($Content, $pos, $slice, 0, $len)

        $resp = Invoke-EntraRequest -Service $Service -Path $UploadUrl -Method Put -Header $headers -Body $slice -ErrorAction Stop -NoAuthRelativeUrl
        if ($pos + $len -ge $total -and $resp) { return $resp }
        $pos += $len
    }
    $null
}
