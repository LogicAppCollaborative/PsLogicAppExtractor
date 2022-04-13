<#
.SYNOPSIS
Remove parm (parameter) from the LogicApp

.DESCRIPTION
Removes an LogicApp parm (parameter) by the name provided

.PARAMETER InputObject
The LogicApp object that you want to work against

It has to be a object of the type [LogicApp] for it to work properly

.PARAMETER Name
Name of the parm (parameter) that you want to work against

If the parm (parameter) exists, it will be removed from the InputObject

.EXAMPLE
PS C:\> Remove-LogicAppParm -InputObject $armObj -Name "TriggerQueue"

Removes the TriggerQueue LogicApp parm (parameter)

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Remove-LogicAppParm {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Alias('ParmName')]
        [Parameter(Mandatory = $true)]
        [string] $Name
    )
    
    if ($InputObject.properties.definition.parameters.$Name) {
        $InputObject.properties.definition.parameters.PsObject.Properties.Remove($Name)
    }

    $InputObject
}