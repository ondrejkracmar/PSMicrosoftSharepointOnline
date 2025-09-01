function New-PSMsSPOUploadSessionBody {
    <#
    .SYNOPSIS
        Builds the request body for Microsoft Graph createUploadSession.

    .DESCRIPTION
        Produces the payload for POST ...:/createUploadSession with:
          - item.'@microsoft.graph.conflictBehavior' (replace/rename/fail)
          - item.name

    .PARAMETER FileName
        Target file name to be created (or replaced/renamed as per behavior).

    .PARAMETER ConflictBehavior
        Conflict behavior: replace (default), rename, or fail.

    .OUTPUTS
        System.Collections.Hashtable

    .EXAMPLE
        $body = New-PSMsSPOUploadSessionBody -FileName 'bigfile.bin' -ConflictBehavior rename
        # POST to ...:/createUploadSession with $body
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)
        ][string] $FileName,
        [ValidateSet('replace', 'rename', 'fail')
        ][string] $ConflictBehavior = 'replace'
    )
    @{
        item = @{
            '@microsoft.graph.conflictBehavior' = $ConflictBehavior
            'name'                              = $FileName
        }
    }
}
