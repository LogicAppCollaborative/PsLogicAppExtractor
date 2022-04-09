<#
.SYNOPSIS
Remove variable from the ARM template

.DESCRIPTION
Removes an ARM template variable by the name provided

.PARAMETER InputObject
The ARM object that you want to work against

It has to be a object of the type [ArmTemplate] for it to work properly

.PARAMETER Name
Name of the variable that you want to work against

If the variable exists, it will be removed from the InputObject

.EXAMPLE
PS C:\> Remove-ArmVariable -InputObject $armObj -Name "logicAppName"

Removes the logicAppName ARM template variable

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Remove-ArmVariable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Alias('VariableName')]
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    if ($InputObject.variables.$Name) {
        $InputObject.variables.PsObject.Properties.Remove($Name)
    }

    $InputObject
}