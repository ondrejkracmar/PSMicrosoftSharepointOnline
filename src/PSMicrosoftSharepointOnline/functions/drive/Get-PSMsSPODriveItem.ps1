function Get-PSMsSPODriveItem {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Lists items in a SharePoint/Teams document library (non-recursive).

    .DESCRIPTION
        Resolves drive by SiteUrl(+DriveName) or GroupId (Teams default drive).

    .PARAMETER SiteUrl
        Full site URL, e.g. https://contoso.sharepoint.com/sites/ProjectX

    .PARAMETER DriveName
        Optional drive (library) displayName, e.g. 'Documents'.

    .PARAMETER GroupId
        M365 Group / Teams Id (GUID) ⇒ default drive.

    .PARAMETER FolderPath
        Folder path relative to drive root (default root).

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        Get-PSMsSharePointDriveItem -SiteUrl https://contoso.sharepoint.com/sites/ProjX -DriveName Documents -SubfolderPath 'Specs'
    #>
    [OutputType('PSMicrosoftTeams.Files.Drives.DriveItem')]
    [CmdletBinding(DefaultParameterSetName = 'Site')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Site')]
        [ValidateNotNullOrEmpty()] [string] $SiteUrl,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Site')]
        [string] $DriveName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Group')]
        [ValidateNotNullOrEmpty()] [string] $GroupId,
        [string] $FolderPath = '',
        [switch] $EnableException
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $query = @{
            #'$count' = 'true'
            '$top' = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.DriveItem).Value -join ',')
        }
        [hashtable] $header = @{}
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Group' {
                [PSMicrosoftSharePointOnline.Files.Drives.Drive] $drive = Get-PSMsSPODrive -GroupId $GroupId
                if ([object]::Equals($drive, $null)) {
                    Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name DriveItemGroup.Get.Failed) -f $GroupId, $FolderPath)
                }
            }
            'Site' {
                [PSMicrosoftSharePointOnline.Files.Drives.Drive[]] $driveNameList = Get-PSMsSPODrive -SiteUrl $SiteUrl -DriveName $DriveName
                if ([object]::Equals($driveNameList, $null)) {
                    Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name DriveItemSite.Get.Failed) -f $DriveName, $SiteUrl, $FolderPath)
                }
            }
        }
        [PSMicrosoftSharePointOnline.Files.Drives.Drive] $drive = $driveNameList | Where-Object -Property Name -Value $DriveName -EQ
        $path = if ([string]::IsNullOrEmpty($FolderPath.Trim('/'))) {
            "drives/{0}/root/children" -f $drive.Id
        }
        else {
            "drives/{0}/root:/{1}:/children" -f $drive.Id, ([uri]::EscapeDataString($FolderPath.Trim('/')))
        }

        Invoke-PSFProtectedCommand -ActionString 'DriveItem.Get' -ActionStringValues $DriveName, $FolderPath -Target $SiteUrl -ScriptBlock {
            [PSMicrosoftSharePointOnline.Sites.Site] $site = Get-PsMsSPOSite -SiteUrl $SiteUrl
            ConvertFrom-RestDriveItem -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop)
        } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
    }

}
