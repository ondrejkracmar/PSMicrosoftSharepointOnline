function Get-PSMsSPODrive {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Resolve a SharePoint/Teams document library (drive) via Microsoft Graph.

    .DESCRIPTION
        Returns a single drive for either:
          - SharePoint site identified by -SiteUrl (optionally filtered by -DriveName), or
          - Microsoft 365 Group / Teams identified by -GroupId (default team drive).

    .PARAMETER SiteUrl
        Full SharePoint site URL, e.g. https://contoso.sharepoint.com/sites/ProjectX.

    .PARAMETER DriveName
        Optional display name of the document library (e.g., 'Documents').
        If omitted for -SiteUrl, the first site drive is returned.

    .PARAMETER GroupId
        Microsoft 365 Group / Teams Id (GUID). Returns the team's default drive.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        Get-PSMsSharePointDrive -SiteUrl https://contoso.sharepoint.com/sites/ProjX -DriveName Documents

    .EXAMPLE
        Get-PSMsSharePointDrive -GroupId 11111111-2222-3333-4444-555555555555
    #>
    [OutputType('PSMicrosoftTeams.Files.Drives.Drive')]
    [CmdletBinding(DefaultParameterSetName = 'Site')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Site')]
        [ValidateNotNullOrEmpty()]
        [string] $SiteUrl,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Site')]
        [string] $DriveName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Group')]
        [ValidateNotNullOrEmpty()]
        [string] $GroupId,
        [Parameter()]
        [switch] $EnableException
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $query = @{
            #'$count' = 'true'
            '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Drive).Value -join ',')
        }
        [hashtable] $header = @{}
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Group' {
                Invoke-PSFProtectedCommand -ActionString 'DriveGroup.Get' -Target $GroupId -ScriptBlock {
                    ConvertFrom-RestDrive -InputObject (Invoke-EntraRequest -Service $service -Path ("groups/{0}/drive" -f $GroupId) -Query $query -Header $header -Method Get -ErrorAction Stop)
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
            }
            'Site' {
                Invoke-PSFProtectedCommand -ActionString 'DriveSite.Get' -ActionStringValues $DriveName -Target $SiteUrl -ScriptBlock {
                    [PSMicrosoftSharePointOnline.Sites.Site] $site = Get-PsMsSPOSite -SiteUrl $SiteUrl
                    ConvertFrom-RestDrive -InputObject (Invoke-EntraRequest -Service $service -Path ('sites/{0}/drives' -f $site.Id) -Query $query -Header $header -Method Get -ErrorAction Stop)
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
            }
        }
    }

    end {}
}
