function Move-PSMsSPOFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Move a file or folder in SharePoint Online / Teams to another directory.

    .DESCRIPTION
        Uses Microsoft Graph PATCH /drives/{drive-id}/items/{item-id}
        to update the parentReference (target folder).
        Optionally allows renaming at the same time.

    .PARAMETER DriveId
        Target drive identifier.

    .PARAMETER ItemId
        The Id of the file or folder to move.

    .PARAMETER DestinationFolderId
        The Id of the destination folder item (container) within the same drive.

    .PARAMETER NewName
        Optional new name for the item when moved.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .PARAMETER WhatIf
        Enables the function to simulate what it will do instead of actually executing.

    .PARAMETER Force
        The Force switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Force switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

    .PARAMETER Confirm
        The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

    .PARAMETER PassThru
        When specified, the cmdlet will not execute the disable license action but will instead
        return a `PSMicrosoftEntraID.Batch.Request` object for batch processing.

    .EXAMPLE
        Move-PSMsSPOFile -DriveId $drive.Id -ItemId $file.Id -DestinationFolderId $target.Id

        Moves the specified file into the new folder.

    .EXAMPLE
        Move-PSMsSPOFile -DriveId $drive.Id -ItemId $file.Id -DestinationFolderId $target.Id -NewName 'renamed.docx'

        Moves and renames the file at the same time.
    #>
    [OutputType('PSMsSPO.DriveItem')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string] $DriveId,
        [Parameter(Mandatory = $true)]
        [string] $ItemId,
        [Parameter(Mandatory = $true)]
        [string] $DestinationFolderId,
        [Parameter()]
        [string] $NewName,
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
        [string] $path = "drives/{0}/items/{1}" -f $DriveId, $ItemId
        [hashtable] $body = @{
            parentReference = @{ id = $DestinationFolderId }
        }
        if ($PSBoundParameters.ContainsKey('NewName')) {
            $body['name'] = $NewName
        }
        
        if ($PassThru) {
            [PSMicrosoftEntraID.Batch.Request] @{
                Method  = 'PATCH'
                Url     = ('/{0}' -f $path)
                Body    = $body
                Headers = @{ 'Content-Type' = 'application/json' }
            }
        }
        else {
            Invoke-PSFProtectedCommand -ActionString 'DriveItem.Move' -ActionStringValues $ItemId, $DestinationFolderId -Target $DriveId -ScriptBlock {
                Invoke-EntraRequest -Service $service -Path $path -Method Patch -Header $header -Body $body -ErrorAction Stop
            } -EnableException:$EnableException -Confirm:$false -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
        }
    }

    end {}
}
