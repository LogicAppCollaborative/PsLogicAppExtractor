<#
.SYNOPSIS
Get the header for a build file

.DESCRIPTION
Gets the header for a build file, containing the sane defaults

Allows you to prepare the build file as much as possible, based on the parameters that you pass to it

.PARAMETER SubscriptionId
Id of the subscription that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session either needs to "connected" to the subscription or at least have permissions to work against the subscription

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

.PARAMETER ResourceGroup
Name of the resource group that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session needs to have permissions to work against the resource group

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

.PARAMETER Name
Name of the logic app, that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session needs to have permissions to work against the logic app

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

.PARAMETER ApiVersion
The ApiVersion that you want the LogicApp to be working against

The default value is: "2019-05-01"

.PARAMETER IncludePrefixSuffix
Instruct the cmdlet to add the different prefix and suffix options, with the default values that comes with the module

This make it easier to make the build file work across different environments, without having to worry about prepping different prefix and suffix value prior

.EXAMPLE
PS C:\> Get-BuildHeader

Creates the bare minimum header for the build file
Prepares the Properties object with sane defaults, allowing you to edit them after the file has been created

.EXAMPLE
PS C:\> Get-BuildHeader -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg"

Creates the bare minimum header for the build file
Prepares the Properties object with SubscriptionId and ResourceGroup, and sane defaults for the remaining objects, allowing you to edit them after the file has been created

.EXAMPLE
PS C:\> Get-BuildHeader -Name "TestLogicApp" -ApiVersion "2019-05-01"

Creates the bare minimum header for the build file
Prepares the Properties object with Name and ApiVersion, and sane defaults for the remaining objects, allowing you to edit them after the file has been created

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Get-BuildHeader {
    [CmdletBinding()]
    param (
        [string] $SubscriptionId,

        [string] $ResourceGroup,

        [string] $Name,

        [string] $ApiVersion = "2019-05-01",

        [switch] $IncludePrefixSuffix
    )

    $res = New-Object System.Collections.Generic.List[System.Object]

    $res.Add("# Object to store the needed parameters for when running the export")
    $res.Add("Properties {")
    
    if ($SubscriptionId) {
        $res.Add('$SubscriptionId = "{0}"' -f $SubscriptionId)
    }
    else {
        $res.Add('$SubscriptionId = $null')
    }

    if ($ResourceGroup) {
        $res.Add('$ResourceGroup = "{0}"' -f $ResourceGroup)
    }
    else {
        $res.Add('$ResourceGroup = $null')
    }
    
    if ($Name) {
        $res.Add('$Name = "{0}"' -f $Name)
    }
    else {
        $res.Add('$Name = "ChangeThis"')
    }

    if ($ApiVersion) {
        $res.Add('$ApiVersion = "{0}"' -f $ApiVersion)
    }
    else {
        $res.Add('$ApiVersion = "ChangeThis"')
    }

    $res.Add('$PsLaWorkPath = ""')
    
    if ($IncludePrefixSuffix) {
        $res.Add('$Tag_Prefix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.tag.prefix))
        $res.Add('$Tag_Suffix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.tag.suffix))

        $res.Add('$Parm_Prefix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.parm.prefix))
        $res.Add('$Parm_Suffix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.parm.suffix))

        $res.Add('$Connection_Prefix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix))
        $res.Add('$Connection_Suffix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.suffix))

        $res.Add('$Trigger_Prefix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.trigger.prefix))
        $res.Add('$Trigger_Suffix = "{0}"' -f $(Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.trigger.suffix))
    }

    $res.Add('}')
    #Above line completes the Properties declaration

    $res.Add('')
    $res.Add('# Used to import the needed classes into the powershell session, to help with the export of the Logic App')
    $res.Add('."$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes)\PsLogicAppExtractor.class.ps1"')
    $res.Add('')
    $res.Add('# Used to keep track of the tasks, and their sequence of execution. Usefull for diagnostics and troubleshooting')
    $res.Add('$Script:TaskCounter = 0')
    $res.Add('')

    $res
}