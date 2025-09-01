function Remove-PSMsSPOFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Remove (delete) a file from SharePoint Online / Teams.

    .DESCRIPTION
        Deletes a file (or folder) from a document library using Microsoft Graph.
        Requires both the drive Id and the item Id of the file/folder.

        Graph endpoint:
          DELETE /drives/{drive-id}/items/{item-id}

    .PARAMETER DriveId
        Target drive identifier.

    .PARAMETER ItemId
        Identifier of the file or folder to delete.

    .PARAMETER EnableException
        Throw terminating exceptions instead of user-friendly errors; allows try/catch.

    .PARAMETER PassThru
        When specified, returns a `PSMicrosoftEntraID.Batch.Request` object for batch processing
        instead of executing immediately.

    .EXAMPLE
        PS> Remove-PSMsSPOFile -DriveId $drive.Id -ItemId $file.Id -Confirm:$false

        Deletes the specified file from the drive.

    .EXAMPLE
        PS> Remove-PSMsSPOFile -DriveId $drive.Id -ItemId $file.Id -PassThru

        Returns a batch request object representing the DELETE call.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $DriveId,
        [Parameter(Mandatory = $true)]
        [string] $ItemId,
        [Parameter()]
        [switch] $EnableException,
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $header = @{
            'Content-Type' = 'application/json'
        }
        [hashtable] $body = @{}
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
    }

    process {
        $path = "drives/{0}/items/{1}" -f $DriveId, $ItemId
        if ($PassThru) {
            [PSMicrosoftEntraID.Batch.Request] @{
                Method  = 'DELETE'
                Url     = ('/{0}' -f $path)
                Body    = $null
                Headers = @{}
            }
        }
        else {
            Invoke-PSFProtectedCommand -ActionString 'DriveItem.Remove' -ActionStringValues $ItemId -Target $DriveId -ScriptBlock {
                Invoke-EntraRequest -Service $service -Path $path -Method Delete -header $header -ErrorAction Stop
            } -EnableException $EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $retryCount -RetryWait $retryWait
        }
    }

    end {}
}
