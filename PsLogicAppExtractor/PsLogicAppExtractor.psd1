@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'PsLogicAppExtractor.psm1'
	
	# Version number of this module.
	ModuleVersion     = '1.0.0'
	
	# ID used to uniquely identify this module
	GUID              = 'a8d35904-1748-4271-9970-a0520b13c9c4'
	
	# Author of this module
	Author            = 'Mötz Jensen'
	
	# Company or vendor of this module
	CompanyName       = 'Essence Solutions'
	
	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2022 Mötz Jensen'
	
	# Description of the functionality provided by this module
	Description       = 'A set of tools that will assist you with extracting / exporting Azure Logic Apps, and turn them into a fully working ARM template. It contains of several small tasks, which can be configured to meet your needs.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.6.214' }
		, @{ ModuleName = 'psake'; ModuleVersion = '4.9.0' }
		, @{ ModuleName = 'newtonsoft.json'; ModuleVersion = '1.0.2.201' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\PsLogicAppExtractor.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\PsLogicAppExtractor.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\PsLogicAppExtractor.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = ''
	
	# Cmdlets to export from this module
	CmdletsToExport   = ''
	
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
			Tags       = @('LogicApp', 'Azure', 'Arm', 'ArmTemplate', 'Microsoft.Logic/workflows', 'Microsoft.Logic', 'workflows')
			
			# A URL to the license for this module.
			LicenseUri = "https://opensource.org/licenses/MIT"
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/LogicAppCollaborative/PsLogicAppExtractor'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}