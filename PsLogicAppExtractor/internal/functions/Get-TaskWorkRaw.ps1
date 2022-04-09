<#
.SYNOPSIS
Get the object that the task has to work against, as a raw string

.DESCRIPTION
Gets the object from the "previous" task, based on the persisted path and loads it into memory using Get-Content

.PARAMETER FilePath
Path to the file that you want the task to work against

The default value is: $Script:FilePath

Which is used by all tasks to persist the file path from their completed work

.EXAMPLE
PS C:\> Get-TaskWorkObject

Returns the object that is stored at the location from the $Script:FilePath variable

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Get-TaskWorkRaw {
    [CmdletBinding()]
    param (
        $FilePath = $Script:FilePath
    )

    Get-Content -Path $FilePath -Raw
}