function Save-PSMsSPOFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Save (download) a SharePoint/Teams file to local disk – pipeline from Get-PSMsSPODriveItem.

    .DESCRIPTION
        Designed to work directly with PSMsSPO.DriveItem objects produced by Get-PSMsSPODriveItem.
        Uses Microsoft Graph:
          - GET /drives/{drive-id}/items/{item-id}/content
          - GET /drives/{drive-id}/root:/{path}/{name}:/content  (fallback)

    .PARAMETER InputObject
        Pipeline object from Get-PSMsSPODriveItem (PSTypeName 'PSMsSPO.DriveItem').

    .PARAMETER DriveId
        Drive identifier

    .PARAMETER ItemId
        Item identifier

    .PARAMETER FileName
        Item name

    .PARAMETER FolderPath
        Drive-root relative path of the parent + item (without '/drive/root:' prefix).
        In our list cmdlet it's the computed relative path to the item (ValueFromPipelineByPropertyName).

    .PARAMETER OutFile
        Full local file path. If omitted, file is saved under -OutputDirectory with the pipeline item Name.

    .PARAMETER OutputDirectory
        Target directory (used when -OutFile not provided). Defaults to current location.

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
        PS C:\> Get-PSMsSPODriveItem -SiteUrl https://contoso/sites/ProjX -DriveName Documents -FolderPath 'Specs' | Save-PSMsSPOFile -OutputDirectory 'C:\Temp'

    #>
    [OutputType('System.IO.FileInfo')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'InputObject')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [PSMicrosoftSharepointOnline.Files.Drives.DriveItem[]] $InputObject,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Name')]
        [string] $DriveId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias("Id")]
        [string] $ItemId,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [string] $OutFile,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Name')]
        [string] $FolderPath,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Name')]
        [string] $FileName,
        [ValidateDirectoryExists()]
        [string] $OutputDirectory = (Get-Location).Path,
        [Parameter()]
        [switch] $EnableException,
        [Parameter()]
        [switch] $Force,
        [Parameter()]
        [switch]$PassThru
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
        switch ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                foreach ($itemInputObject in $InputObject) {
                    $path = 'drives/{0}/items/{1}/content' -f $itemInputObject.ParentReference.DriveId, $itemInputObject.Id
                    if ($PassThru.IsPresent) {
                        [PSMicrosoftEntraID.Batch.Request] @{ Method = 'GET'; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                    }
                    else {
                        $target = Join-Path -Path ($OutputDirectory | Resolve-Path).Path -ChildPath $itemInputObject.Name
                        Invoke-PSFProtectedCommand -ActionString 'DriveItem.Save' -ActionStringValues $itemInputObject.Id, $target -Target $itemInputObject.WebUrl -ScriptBlock {
                            [byte[]] $bytes = Convert-PSMsSPOResponseToBytes -InputObject (Invoke-EntraRequest -Service $service -Path $path -Method Get -Header $header -Raw -ErrorAction Stop)
                            [System.IO.File]::WriteAllBytes($target, $bytes)
                            Get-Item -Path $target -Force
                        } -EnableException $EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    }
                }
            }
            'Id' {
                $path = 'drives/{0}/items/{1}/content' -f $DriveId, $ItemId
                if ($PassThru.IsPresent) {
                    [PSMicrosoftEntraID.Batch.Request] @{ Method = 'GET'; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                }
                else {
                    If ([object]::Equals($OutFile, $null)) {
                        $target = Join-Path -Path ($FolderPath | Resolve-Path).Path -ChildPath 'download.bin'
                    }
                    else {
                        $target = Join-Path -Path ($FolderPath | Resolve-Path).Path -ChildPath $OutFile
                    }
                    Invoke-PSFProtectedCommand -ActionString 'DriveItem.Save' -ActionStringValues  $ItemId, $target -Target $DriveId -ScriptBlock {
                        [byte[]] $bytes = Convert-PSMsSPOResponseToBytes -InputObject (Invoke-EntraRequest -Service $service -Path $path -Method Get -Header $header -Raw -ErrorAction Stop)
                        [System.IO.File]::WriteAllBytes($target, $bytes)
                        Get-Item -Path $target -Force
                    } -EnableException $EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                }
            }
            'Name' {
                $path = 'drives/{0}/root:/{1}/{2}:/content' -f $DriveId, $ItemId, $FolderPath.Trim('/'), $FileName
                if ($PassThru.IsPresent) {
                    [PSMicrosoftEntraID.Batch.Request] @{ Method = 'GET'; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                }
                else {
                    $target = Join-Path -Path ($FolderPath | Resolve-Path).Path -ChildPath $FileName
                    Invoke-PSFProtectedCommand -ActionString 'DriveItem.Save' -ActionStringValues $ItemId, $target -Target $DriveId -ScriptBlock {
                        [byte[]] $bytes = Convert-PSMsSPOResponseToBytes -InputObject (Invoke-EntraRequest -Service $service -Path $path -Method Get -Header $header -Raw -ErrorAction Stop)
                        [System.IO.File]::WriteAllBytes($target, $bytes)
                        Get-Item -Path $target -Force
                    } -EnableException $EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait

                }
            }
        }
    }
    end {}
}
