﻿<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration

#>


$script:ModuleName = 'PSMicrosoftSharepointOnline'

Set-PSFConfig -Module $script:ModuleName -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module $script:ModuleName -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."

Set-PSFConfig -Module $script:ModuleName -Name 'Settings.Command.RetryWaitInSeconds' -Value 0 -Initialize -Validation 'integer' -Description "Value of parameter RetryWait in the Invoke-PSFProtectedCommand."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.Command.RetryCount' -Value 0 -Initialize -Validation 'integer' -Description "Value of parameter RetryCount in the Invoke-PSFProtectedCommand."

Set-PSFConfig -Module $script:ModuleName -Name 'Settings.DefaultService' -Value $script:_DefaultService -Initialize -Validation 'string' -Description "What service name of Microsoft EntraID."

Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Warning' -Value $true -Validation 'bool' -Description "Whether a warning will be displayed in cmdlets."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Format' -Value 'json' -Initialize -Validation 'string' -Description "Specifies the media format of the items returned from Microsoft Graph Api."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Query.Level' -Value 'Default' -Initialize -Validation 'string' -Description "Query capabilities level (Default/Advanced). Default value is Default."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Query.AdvancedQueryCapabilities.ConsistencyLevel ' -Value 'eventual' -Initialize -Validation 'string' -Description "Advanced query capabilities ConsistencyLevel settings."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.PageSize' -Value 100 -Initialize -Validation 'integer' -Description "Value of parameter PageSize invoke rest query."

Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.Site' -Value @('id', 'name', 'displayName', 'description', 'webUrl', 'createdDateTime', 'lastModifiedDateTime', 'siteCollection') -Initialize -Validation 'stringarray' -Description "Specifies uery parameter to return a set of properties that are different than the default set for an individual resource or a collection of resources."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.Drive' -Value @('id', 'name', 'description', 'webUrl', 'createdDateTime', 'lastModifiedDateTime', 'driveType', 'quota') -Initialize -Validation 'stringarray' -Description "Specifies uery parameter to return a set of properties that are different than the default set for an individual resource or a collection of resources."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.DriveItem' -Value @('id', 'name', 'webUrl', 'eTag', 'cTag', 'size', 'createdDateTime', 'lastModifiedDateTime', 'file', 'folder', 'parentReference') -Initialize -Validation 'stringarray' -Description "Specifies uery parameter to return a set of properties that are different than the default set for an individual resource or a collection of resources."