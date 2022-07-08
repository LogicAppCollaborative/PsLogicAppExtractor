
<#
    .SYNOPSIS
        Output the tasks result to a file, as an ARM template
        
    .DESCRIPTION
        Persists the tasks output into a file, as an ARM template
        
        Notes: It is considered as an internal function, and should not be used directly.
        
    .PARAMETER InputObject
        The object that should be written to the desired path
        
        Will be converted to a json string, usign the ConvertTo-Json
        
    .EXAMPLE
        PS C:\> Out-TaskFileArm -InputObject $armObj
        
        Outputs the armObj variable
        The armObj is casted to the [ArmTemplate] type, to ensure it is persisted as the expected json structure
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
        This is considered as an internal function, and should not be used directly.
#>
function Out-TaskFileArm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject
    )

    Out-TaskFile -InputObject $([ArmTemplate]$InputObject)
}