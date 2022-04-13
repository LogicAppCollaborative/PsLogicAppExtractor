
<#
    .SYNOPSIS
        Add new parm (parameter) to the LogicApp object
        
    .DESCRIPTION
        Adds or overwrites a LogicApp parm (parameter) by the name provided, and allows you to specify the default value and the type
        
    .PARAMETER InputObject
        The ARM object that you want to work against
        
        It has to be a object of the type [LogicApp] for it to work properly
        
    .PARAMETER Name
        Name of the parm (parameter) that you want to work against
        
        If the parm (parameter) exists, the value gets overrided otherwise a new parm (parameter) is added to the list of parms (parameters)
        
    .PARAMETER Type
        The type of the LogicApp parm (parameter)
        
        It supports all known types
        
    .PARAMETER Value
        The default value, that you want to assign to the LogicApp parm (parameter)
        
    .EXAMPLE
        PS C:\> Add-LogicAppParm -InputObject $lgObj -Name "TriggerQueue" -Type "string" -Value "Inbound"
        
        Creates / updates the TriggerQueue LogicApp parm (parameter)
        Sets the type of the parameter to: string
        Sets the default value to: Inbound
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Add-LogicAppParm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Alias('ParmName')]
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [string] $Type,

        [Parameter(Mandatory = $true)]
        [object] $Value
    )

    $valueObj = $([ordered]@{
            type         = $Type;
            defaultValue = $Value;
        })
        
    if ($InputObject.properties.definition.parameters.$Name) {
        $InputObject.properties.definition.parameters.$Name = $($valueObj)
    }
    else {
        $InputObject.properties.definition.parameters | Add-Member -MemberType NoteProperty -Name $Name -Value $valueObj
    }

    $InputObject
}