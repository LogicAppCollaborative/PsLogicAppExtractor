
<#
    .SYNOPSIS
        Remove parameter from the ARM template
        
    .DESCRIPTION
        Removes an ARM template parameter by the name provided
        
    .PARAMETER InputObject
        The ARM object that you want to work against
        
        It has to be a object of the type [ArmTemplate] for it to work properly
        
    .PARAMETER Name
        Name of the parameter that you want to work against
        
        If the parameter exists, it will be removed from the InputObject
        
    .EXAMPLE
        PS C:\> Remove-ArmParameter -InputObject $armObj -Name "logicAppName"
        
        Removes the logicAppName ARM template parameter
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Remove-ArmParameter {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Alias('ParameterName')]
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    if ($InputObject.parameters.$Name) {
        $InputObject.parameters.PsObject.Properties.Remove($Name)
    }

    $InputObject
}