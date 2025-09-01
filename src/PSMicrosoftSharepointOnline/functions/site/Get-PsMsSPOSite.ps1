function Get-PSMsSPOSite {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Get SharePoint Online site metadata via Microsoft Graph.

    .DESCRIPTION
        Resolves and returns a SharePoint site using one of:
          - SiteUrl (e.g., https://contoso.sharepoint.com/sites/ProjectX)
          - Hostname + RelativePath (e.g., contoso.sharepoint.com + /sites/ProjectX)
          - SiteId (Graph composite id: hostname,siteId,webId)

    .PARAMETER SiteUrl
        Full site URL, e.g. https://contoso.sharepoint.com/sites/ProjectX

    .PARAMETER Hostname
        SharePoint hostname, e.g. contoso.sharepoint.com

    .PARAMETER RelativePath
        Site relative path starting with '/', e.g. /sites/ProjectX or /teams/HR

    .PARAMETER SiteId
        Graph site identifier in form hostname,siteId,webId

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.


    .EXAMPLE
        Get-PSMsSPOSite -SiteUrl https://contoso.sharepoint.com/sites/ProjectX

    .EXAMPLE
        Get-PSMsSPOSite -Hostname contoso.sharepoint.com -RelativePath /sites/ProjectX

    .EXAMPLE
        Get-PSMsSPOSite -SiteId 'contoso.sharepoint.com,abc123,def456'
    #>
    [OutputType('PSMicrosoftTeams.Sites.Site')]
    [CmdletBinding(DefaultParameterSetName = 'Site')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Site')]
        [ValidateNotNullOrEmpty()]
        [string] $SiteUrl,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [string] $Hostname,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [string] $RelativePath,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [ValidateNotNullOrEmpty()]
        [string] $SiteId,
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
        [hashtable] $query = @{
            #'$count'  = 'true'
            #'$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Site).Value -join ',')
        }
        [hashtable] $header = @{}
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Site' {
                [uri] $uri = [Uri] $SiteUrl
                [string] $path = 'sites/{0}:{1}' -f $uri.Host, $uri.AbsolutePath
            }
            'Path' {
                [string] $path = 'sites/{0}:{1}' -f $Hostname, $RelativePath
            }
            'Id' {
                [string] $path = 'sites/{0}' -f $SiteId
            }
        }

        Invoke-PSFProtectedCommand -ActionString 'Site.Get' -ActionStringValues $path -Target $path -ScriptBlock {
            ConvertFrom-RestSite -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop)
        } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
    }

    end {}
}
