<#
.SYNOPSIS
Add new parameter to the ARM template

.DESCRIPTION
Adds or overwrites an ARM template parameter by the name provided, and allows you to specify the default value, type and the metadata decription

.PARAMETER InputObject
The ARM object that you want to work against

It has to be a object of the type [ArmTemplate] for it to work properly

.PARAMETER Name
Name of the parameter that you want to work against

If the parameter exists, the value gets overrided otherwise a new parameter is added to the list of parameters

.PARAMETER Type
The type of the ARM template parameter

It supports all known types

.PARAMETER Value
The default value, that you want to assign to the ARM template parameter

.PARAMETER Description
The metadata description that you want to assign to the ARM template parameters

.EXAMPLE
PS C:\> Add-ArmParameter -InputObject $armObj -Name "logicAppName" -Type "string" -Value "TestLogicApp"

Creates / updates the logicAppName ARM template parameter
Sets the type of the parameter to: string
Sets the default value to: TestLogicApp

.EXAMPLE
PS C:\> Add-ArmParameter -InputObject $armObj -Name "logicAppName" -Type "string" -Value "TestLogicApp" -Description "This is the name we extracted from the orignal LogicApp"

Creates / updates the logicAppName ARM template parameter
Sets the type of the parameter to: string
Sets the default value to: TestLogicApp
Sets the metadata description

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Add-ArmParameter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Alias('ParameterName')]
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [string] $Type,

        [Parameter(Mandatory = $true)]
        [object] $Value,

        [string] $Description
    )

    if ($Description) {
        $valueObj = $([ordered]@{
                type         = $Type;
                defaultValue = $Value;
                metadata     = [ordered]@{
                    description = $Description
                }
            })

    }
    else {
        $valueObj = $([ordered]@{
                type         = $Type;
                defaultValue = $Value;
            })
    }

    if ($InputObject.parameters.$Name) {
        $InputObject.parameters.$Name = $($valueObj)
    }
    else {
        $InputObject.parameters | Add-Member -MemberType NoteProperty -Name $Name -Value $valueObj
    }
    
    $InputObject
}