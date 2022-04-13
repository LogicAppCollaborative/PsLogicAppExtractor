<#
.SYNOPSIS
Format the name with the prefix and suffix

.DESCRIPTION
Format the name with the prefix and suffix

If the passed prefix and suffix is not $null, then they are used

Otherwise the cmdlet will default back to the configuration for each type, that is persisted in the configuration store

.PARAMETER Type
The type of name that you want to work against

Allowed values:
Tag
Connection
Parameter
Parm

.PARAMETER Prefix
The prefix that you want to append to the name

If empty / $null - then the cmdlet will use the prefix that is stored for the specific type

.PARAMETER Suffix
The suffix that you want to append to the name

If empty / $null - then the cmdlet will use the suffix that is stored for the specific type

.PARAMETER Value
The string value that you want to have the prefix and suffix concatenated with

.EXAMPLE
PS C:\> Format-Name -Type "Tag" -Value "CostCenter"

Formats the value: CostCenter with the default prefix and suffix for the type: Tag
The default prefix is: tag_
The default suffix is: $null

The output will be: tag_CostCenter

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Format-Name {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [CmdletBinding()]
    param (
        [ValidateSet('Tag', 'Connection', 'Parameter', 'Parm', 'Trigger')]
        [Parameter(Mandatory = $true)]
        [string] $Type,

        [string] $Prefix,

        [string] $Suffix,

        [Alias('Name')]
        [Parameter(Mandatory = $true)]
        [string] $Value
    )
    
    switch ($Type) {
        "Tag" {
            if ($Prefix -or $Suffix) {
                "$Prefix$Value$Suffix"
            }
            else {
                $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.tag.prefix
                $Suffix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.tag.suffix

                "$Prefix$Value$Suffix"
            }
        }
        "Connection" {
            if ($Prefix -or $Suffix) {
                "$Prefix$Value$Suffix"
            }
            else {
                $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
                $Suffix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.suffix

                "$Prefix$Value$Suffix"
            }
        }
        "Parameter" {  }
        "Parm" {
            if ($Prefix -or $Suffix) {
                "$Prefix$Value$Suffix"
            }
            else {
                $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.parm.prefix
                $Suffix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.parm.suffix

                "$Prefix$Value$Suffix"
            }
        }
        "Trigger" {
            if ($Prefix -or $Suffix) {
                "$Prefix$Value$Suffix"
            }
            else {
                $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.trigger.prefix
                $Suffix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.trigger.suffix

                "$Prefix$Value$Suffix"
            }
        }
        Default { "$Prefix$Value$Suffix" }
    }
}

<#
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.tag.prefix' -Value "tag_" -Initialize -Description "The default prefix for Tag objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.tag.suffix' -Value "" -Initialize -Description "The default suffix for Tag objects, used as a fallback value for the Format-Name cmdlet. Be default an empty string"

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.tag.prefix' -Value "tag_" -Initialize -Description "The default prefix for Tag objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.tag.suffix' -Value "" -Initialize -Description "The default suffix for Tag objects, used as a fallback value for the Format-Name cmdlet. Be default an empty string."

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.parm.prefix' -Value "parm_" -Initialize -Description "The default prefix for parm (parameter) objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.parm.suffix' -Value "" -Initialize -Description "The default suffix for parm (parameter) objects, used as a fallback value for the Format-Name cmdlet. Be default an empty string."

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.connection.prefix' -Value "connection_" -Initialize -Description "The default prefix for connection objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.connection.suffix' -Value "_id" -Initialize -Description "The default suffix for connection objects, used as a fallback value for the Format-Name cmdlet."

Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.trigger.prefix' -Value "trigger_" -Initialize -Description "The default prefix for trigger objects, used as a fallback value for the Format-Name cmdlet."
Set-PSFConfig -Module 'PsLogicAppExtractor' -Name 'prefixsuffix.trigger.suffix' -Value "" -Initialize -Description "The default suffix for trigger objects, used as a fallback value for the Format-Name cmdlet. Be default an empty string."

#>