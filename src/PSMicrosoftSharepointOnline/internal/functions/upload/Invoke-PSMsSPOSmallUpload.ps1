function Invoke-PSMsSPOSmallUpload {
    <#
    .SYNOPSIS
        Performs a small (<= 4 MB) PUT upload to Microsoft Graph.

    .DESCRIPTION
        Sends a single PUT request to a Graph :/content endpoint with either binary bytes (byte[])
        or text (string). If -ETag is provided, adds If-Match. Content-Type is set appropriately.

    .PARAMETER Service
        Entra service name for Invoke-EntraRequest.

    .PARAMETER Path
        Relative Graph URL (e.g. 'drives/{id}/root:/path/file.ext:/content?...').

    .PARAMETER Content
        (Binary set) Raw bytes to upload.

    .PARAMETER TextContent
        (Text set) Text to upload as a string.

    .PARAMETER Encoding
        (Text set) Encoding for the text body (affects charset in header). Default UTF8.

    .PARAMETER ContentType
        (Text set) MIME type for text body. If no charset present, it’s appended.

    .PARAMETER ETag
        Optional If-Match header value.

    .OUTPUTS
        Microsoft Graph driveItem (as returned by Invoke-EntraRequest).
    #>
    [CmdletBinding(DefaultParameterSetName='Binary')]
    param(
        [Parameter(Mandatory)]
        [string] $Service,
        [Parameter(Mandatory)]
        [string] $Path,
        [Parameter(Mandatory, ParameterSetName='Binary')]
        [byte[]] $Content,
        [Parameter(Mandatory, ParameterSetName='Text')]
        [string] $TextContent,
        [Parameter(ParameterSetName='Text')]
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8,
        [Parameter(ParameterSetName='Text')]
        [ValidateNotNullOrEmpty()]
        [string] $ContentType = 'text/plain',
        [Parameter()]
        [string] $ETag
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Binary' {
            $headers = @{ 'Content-Type' = 'application/octet-stream' }
            if ($ETag) { $headers['If-Match'] = $ETag }
            Invoke-EntraRequest -Service $Service -Path $Path -Method Put -Header $headers -Body $Content -ErrorAction Stop
        }
        'Text' {
            $ct = if ($ContentType -match ';') { $ContentType } else { '{0}; charset={1}' -f $ContentType, $Encoding.WebName }
            $headers = @{ 'Content-Type' = $ct }
            if ($ETag) { $headers['If-Match'] = $ETag }
            Invoke-EntraRequest -Service $Service -Path $Path -Method Put -Header $headers -Body $TextContent -ErrorAction Stop
        }
    }
}
