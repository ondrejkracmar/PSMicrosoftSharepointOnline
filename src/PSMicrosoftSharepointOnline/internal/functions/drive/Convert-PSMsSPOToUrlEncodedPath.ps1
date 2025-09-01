function Convert-PSMsSPOToUrlEncodedPath {
    <#
    .SYNOPSIS
        URL-encodes a drive-root relative path for Microsoft Graph.

    .DESCRIPTION
        Splits the provided relative path by '/', URL-encodes each segment using
        [uri]::EscapeDataString(), and re-joins the segments with '/'.
        The '/drive/root:' prefix MUST NOT be present and is not expected.

    .PARAMETER RelativePath
        The drive-root relative path to encode. Can be empty or nested
        (e.g., 'Folder A/Sub B').

    .NOTES
        Internal helper for building Graph paths like:
        drives/{driveId}/root:/{encodedPath}/{fileName}:/content
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RelativePath
    )
    if ([string]::IsNullOrWhiteSpace($RelativePath)) { return '' }

    # Rozděl → URL-encode každý segment → znovu spoj lomítky
    $segments = $RelativePath.Trim('/') -split '/'
    ($segments | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
}
