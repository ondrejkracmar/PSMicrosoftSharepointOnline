function Get-PSMsSPOPutPathById {
    <#
    .SYNOPSIS
        Builds a Microsoft Graph PUT content path by parent item Id.

    .DESCRIPTION
        Returns a Graph relative URL suitable for uploading file content into
        a specific container identified by its item Id:
          PUT /drives/{drive-id}/items/{parent-id}:/{fileName}:/content?@microsoft.graph.conflictBehavior={behavior}

    .PARAMETER DriveId
        The target drive identifier.

    .PARAMETER ParentItemId
        The parent folder item Id (container) where the file should be uploaded.

    .PARAMETER FileName
        Target file name in the document library.

    .PARAMETER ConflictBehavior
        Conflict behavior when a file already exists: 'replace' (default), 'rename', or 'fail'.

    .EXAMPLE
        PS> Get-PSMsSPOPutPathById -DriveId $d -ParentItemId $p -FileName 'report.docx'
        drives/{driveId}/items/{parentId}:/report.docx:/content?@microsoft.graph.conflictBehavior=replace

    .NOTES
        Used by small PUT and upload session creation.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $DriveId,
        [Parameter(Mandatory)][string] $ParentItemId,
        [Parameter(Mandatory)][string] $FileName,
        [ValidateSet('replace', 'rename', 'fail')][string] $ConflictBehavior = 'replace'
    )
    $nameEnc = [uri]::EscapeDataString($FileName)
    $q = "@microsoft.graph.conflictBehavior=$ConflictBehavior"
    "drives/{0}/items/{1}:/{2}:/content?{3}" -f $DriveId, $ParentItemId, $nameEnc, $q
}