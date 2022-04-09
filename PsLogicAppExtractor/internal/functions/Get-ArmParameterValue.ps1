<#
.SYNOPSIS
Get the value from an ARM template parameter

.DESCRIPTION
Gets the current default value from the specified ARM template parameter

.PARAMETER InputObject
The ARM object that you want to work against

It has to be a object of the type [ArmTemplate] for it to work properly

.PARAMETER Name
Name of the parameter that you want to work against

.EXAMPLE
PS C:\> Get-ArmParameterValue -InputObject $armObj -Name "logicAppName"

Gets the default value from the ARM template parameter: logicAppName

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Get-ArmParameterValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Alias('ParameterName')]
        [Parameter(Mandatory = $true)]
        [string] $Name
    )
    
    if ($InputObject.parameters.$Name) {
        $InputObject.parameters.$Name.defaultValue
    }
}