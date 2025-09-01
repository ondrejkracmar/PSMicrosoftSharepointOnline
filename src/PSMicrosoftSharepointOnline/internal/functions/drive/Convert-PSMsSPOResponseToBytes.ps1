function Convert-PSMsSPOResponseToBytes {
    <#
    .SYNOPSIS
        Converts any Microsoft Graph response object into a byte array.

    .DESCRIPTION
        Ensures that responses from Graph API (via Invoke-EntraRequest or similar)
        are always normalized to a [byte[]], so they can be safely written to disk
        with [System.IO.File]::WriteAllBytes().

        Typical cases:
          - Binary files (ZIP, PDF, DOCX, PNG) → Graph usually returns [byte[]] or Stream
          - Text files (TXT, JSON) → may come back as [string]
          - Other objects → converted to string and encoded

    .PARAMETER InputObject
        The response object to convert. Can be [byte[]], [Stream], [string], or other object types.

    .PARAMETER Encoding
        Text encoding to use if the input is a string (or needs string conversion).
        Default is UTF8.

    .OUTPUTS
        System.Byte[]

    .EXAMPLE
        $resp = Invoke-EntraRequest -Service $service -Path $path -Method Get -NoJson
        $bytes = Convert-PSMsSPOResponseToBytes $resp
        [System.IO.File]::WriteAllBytes('C:\Temp\archive.zip', $bytes)

        Downloads a ZIP file from SharePoint and writes it to disk.

    .EXAMPLE
        'Hello World' | Convert-PSMsSPOResponseToBytes -Encoding ASCII

        Encodes a string as ASCII into byte[].

    .NOTES
        - Always call Invoke-EntraRequest with -NoJson for file downloads.
        - Graph may send small text files as [string], larger/binary as [byte[]] or Stream.
        - This cmdlet ensures consistent [byte[]] output in all cases.
    #>
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $InputObject,

        [Parameter()]
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    )

    process {
        if ($null -eq $InputObject) {
            return , ([byte[]]@()) # empty byte array
        }

        switch ($InputObject) {
            { $_ -is [byte[]] } {
                return $InputObject
            }

            { $_ -is [System.IO.Stream] } {
                $ms = New-Object System.IO.MemoryStream
                try {
                    $InputObject.CopyTo($ms)
                    return $ms.ToArray()
                }
                finally {
                    $ms.Dispose()
                }
            }

            { $_ -is [string] } {
                return $Encoding.GetBytes([string]$InputObject)
            }

            default {
                $text = $InputObject | Out-String
                return $Encoding.GetBytes($text)
            }
        }
    }
}
