function Get-PSMsSPOPutPathByPath {
    <#
    .SYNOPSIS
        Builds a Microsoft Graph PUT content path by drive-root relative path.

    .DESCRIPTION
        Returns a Graph relative URL suitable for uploading file content into
        a folder specified by a drive-root relative path:
          PUT /drives/{drive-id}/root:/{encodedPath}/{fileName}:/content?@microsoft.graph.conflictBehavior={behavior}

    .PARAMETER DriveId
        The target drive identifier.

    .PARAMETER FolderPath
        Drive-root relative folder path (e.g., 'Docs/Specs'). Do NOT include '/drive/root:'.

    .PARAMETER FileName
        Target file name in the document library.

    .PARAMETER ConflictBehavior
        Conflict behavior when a file already exists: 'replace' (default), 'rename', or 'fail'.

    .EXAMPLE
        PS> Get-PSMsSPOPutPathByPath -DriveId $d -FolderPath 'Docs/Specs' -FileName 'report.docx'

        drives/{driveId}/root:/Docs/Specs/report.docx:/content?@microsoft.graph.conflictBehavior=replace

    .NOTES
        Uses Convert-PSMsSPOToUrlEncodedPath to encode each path segment.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $DriveId,
        [Parameter()][string] $FolderPath,
        [Parameter(Mandatory)][string] $FileName,
        [ValidateSet('replace', 'rename', 'fail')][string] $ConflictBehavior = 'replace'
    )
    $rel = Convert-PSMsSPOToUrlEncodedPath -RelativePath $FolderPath
    $nameEnc = [uri]::EscapeDataString($FileName)
    $q = "@microsoft.graph.conflictBehavior=$ConflictBehavior"
    if ($rel) { "drives/{0}/root:/{1}/{2}:/content?{3}" -f $DriveId, $rel, $nameEnc, $q }
    else { "drives/{0}/root:/{1}:/content?{2}" -f $DriveId, $nameEnc, $q }
}