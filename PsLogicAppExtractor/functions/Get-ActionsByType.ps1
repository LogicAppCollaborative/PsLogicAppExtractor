<#
.SYNOPSIS
Get action from the object, filtered by the type of the action

.DESCRIPTION
Get actions and all nested actions, filtered by type

.PARAMETER InputObject
The object that you want to work against

Will by analyzed to see if it has nested actions, and will be recursively traversed to fetch all actions

.PARAMETER Type
The action type that will be outputted

.EXAMPLE
PS C:\> Get-ActionsByType -InputObject $obj -Type "Http"

Will traverse the $obj and filter actions to only output the ones of the type Http

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Get-ActionsByType {
    param (
        [PsCustomObject] $InputObject,

        [string] $Type
    )
    
    if ($InputObject.Type -eq $Type -or $InputObject.Value.Type -eq $Type) {
        $InputObject
    }

    if ($InputObject.Value.actions) {
        foreach ($item in $InputObject.Value.actions.PsObject.Properties) {
            Get-ActionsByType -InputObject $item -Type $Type
        }
    }
    elseif ($InputObject.actions) {
        foreach ($item in $InputObject.actions.PsObject.Properties) {
            Get-ActionsByType -InputObject $item -Type $Type
        }
    }
}