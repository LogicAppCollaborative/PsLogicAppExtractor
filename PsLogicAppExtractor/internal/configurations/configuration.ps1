<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'ModulePath.Base' -Value $script:ModuleRoot -Initialize -Description "The base path for the module, used for the internal functions to be able to provide the full path for internal objects."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'ModulePath.Tasks' -Value "$($script:ModuleRoot)\internal\tasks" -Initialize -Description "The full path for all generic tasks that are part of the module."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'ModulePath.Classes' -Value "$($script:ModuleRoot)\internal\classes" -Initialize -Description "The full path for all the generic classes that are part of the module."


Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.tag.prefix' -Value "tag_" -Initialize -Description "The default prefix for Tag objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.tag.suffix' -Value "" -Initialize -Description "The default suffix for Tag objects, used as a fallback value for the Format-Name cmdlet. Be default an empty string"

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.parm.prefix' -Value "parm_" -Initialize -Description "The default prefix for parm (parameter) objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.parm.suffix' -Value "" -Initialize -Description "The default suffix for parm (parameter) objects, used as a fallback value for the Format-Name cmdlet. Be default an empty string."

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.connection.prefix' -Value "connection_" -Initialize -Description "The default prefix for connection objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.connection.suffix' -Value "_id" -Initialize -Description "The default suffix for connection objects, used as a fallback value for the Format-Name cmdlet."

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.trigger.prefix' -Value "trigger_" -Initialize -Description "The default prefix for trigger objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.trigger.suffix' -Value "" -Initialize -Description "The default suffix for trigger objects, used as a fallback value for the Format-Name cmdlet. Be default an empty string."

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'ModulePath.Queries' -Value "$($script:ModuleRoot)\internal\queries" -Initialize -Description "The full path for all queries used in different cmdlets / functions."