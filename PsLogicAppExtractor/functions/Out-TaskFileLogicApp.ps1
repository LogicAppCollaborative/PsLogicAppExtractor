<#
.SYNOPSIS
Output the tasks result to a file, as a LogicApp json structure

.DESCRIPTION
Persists the tasks output into a file, as a LogicApp json structure

.PARAMETER InputObject
The object that should be written to the desired path

Will be converted to a json string, usign the ConvertTo-Json

.EXAMPLE
PS C:\> Out-TaskFileLogicApp -InputObject $lgObj

Outputs the armObj variable
The armObj is casted to the [ArmTemplate] type, to ensure it is persisted as the expected json structure

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Out-TaskFileLogicApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject
    )

    Out-TaskFile -InputObject $([LogicApp]$InputObject)
}