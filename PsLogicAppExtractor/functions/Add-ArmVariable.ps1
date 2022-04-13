<#
.SYNOPSIS
Add new variable to the ARM template

.DESCRIPTION
Adds or overwrites an ARM template variable by the name provided, and allows you to specify the value

.PARAMETER InputObject
The ARM object that you want to work against

It has to be a object of the type [ArmTemplate] for it to work properly

.PARAMETER Name
Name of the variable that you want to work against

If the variable exists, the value gets overrided otherwise a new variable is added to the list of variables

.PARAMETER Value
The value, that you want to assign to the ARM template variable

.EXAMPLE
PS C:\> Add-ArmVariable -InputObject $armObj -Name "logicAppName" -Value "TestLogicApp"

Creates / updates the logicAppName ARM template variable
Sets the value to: TestLogicApp

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Add-ArmVariable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Alias('VariableName')]
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [object] $Value
    )

    if ($InputObject.variables.$Name) {
        $InputObject.variables.$Name = $($Value)
    }
    else {
        $InputObject.variables | Add-Member -MemberType NoteProperty -Name $Name -Value $($Value)
    }

    $InputObject
}