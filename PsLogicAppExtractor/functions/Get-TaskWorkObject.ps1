
<#
    .SYNOPSIS
        Get the object that the task has to work against
        
    .DESCRIPTION
        Gets the object from the "previous" task, based on the persisted path and loads it into memory using ConvertFrom-Json
        
    .PARAMETER Path
        Path to the file that you want the task to work against
        
    .EXAMPLE
        PS C:\> Get-TaskWorkObject
        
        Returns the object that is stored at the location passed in the Path parameter
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-TaskWorkObject {
    [CmdletBinding()]
    param (
        [string] $Path = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskInputNext)

    )

    Get-Content -Path $Path -Raw | ConvertFrom-Json
}