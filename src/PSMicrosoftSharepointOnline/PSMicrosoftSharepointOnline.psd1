@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'PSMicrosoftSharepointOnline.psm1'
	
	# Version number of this module.
	ModuleVersion     = '0.0.0'
	
	# ID used to uniquely identify this module
	GUID              = '0b3ac2a4-7cb6-45aa-bbf9-20187ce16697'
	
	# Author of this module
	Author            = 'Ondrej Kracmar'
	
	# Company or vendor of this module
	CompanyName       = 'i-system'
	
	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2025 i-system'
	
	# Description of the functionality provided by this module
	Description       = 'PowerShell module for managing SharePoint Online and Teams files.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '7.2'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @('PSFramework'
		#@{ ModuleName = 'PSFramework'; ModuleVersion='1.7'}
		#@{ ModuleName = 'RestConnect'; ModuleVersion='1.0'}
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\PSMicrosoftSharepointOnline.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\PSMicrosoftSharepointOnline.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\PSMicrosoftSharepointOnline.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Connect-PSMicrosoftSharepointOnline'
		'Disconnect-PSMicrosoftSharepointOnline'
		'Get-PSMsSPOSite'
		'Get-PSMsSPODrive'
		'Get-PSMsSPODriveItem'
		'Save-PSMsSPOFile'
		'Send-PSMsSPOFile'
		'Move-PSMsSPOFile'
		'Remove-PSMsSPOFile'
		'Invoke-PSMsSPOBatchRequest'
		'Get-PSMsSPOCommandRetry'
		'Set-PSMsSPOCommandRetry'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport = @('New-PSMsSPOBatchRequest')
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport   = ''
	
	# List of all modules packaged with this module
	ModuleList        = @()
	
	# List of all files packaged with this module
	FileList          = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags                       = @('Rest', 'Azure', 'AzureActiveDirectory', 'MicrosoftEntra', 'MicrosoftEntraID', 'MicrosoftSharepointOnline')

			ExternalModuleDependencies = @('PSFramework')
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}