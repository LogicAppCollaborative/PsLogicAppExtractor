<#
.SYNOPSIS
Get tasks that are references from a file, with the execution order

.DESCRIPTION
Get tasks that are references from a build file, to make it easier to understand what a given build file is doing

Includes the execution order of the tasks, to visualize the tasks sequence

.PARAMETER File
Path to the build file, that you want to analyze

.PARAMETER Detailed
Instruct the cmdlet to output the details about the tasks in a more detailed fashion, makes it easier to read the descriptions for each task

.EXAMPLE
PS C:\> Get-PsLaTaskOrderByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1"

List all tasks that are referenced from the file
The file needs to be a valid PSake build file

Output example:

ExecutionOrder Category  Name                     Description
-------------- --------  ----                     -----------
             1 Exporter  Export-LogicApp.AzCli    Exports the raw version of the Logic App from the Azure Portal
             2 Converter ConvertTo-LogicApp.Basic Converts the raw LogicApp json structure into the a valid LogicApp j…
             3 Converter ConvertTo-Arm            Converts the LogicApp json structure into a valid ARM template json

.EXAMPLE
PS C:\> Get-PsLaTaskOrderByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -Detailed

List all tasks that are referenced from the file, and outputs it in the detailed view
The file needs to be a valid PSake build file

Output example:

ExecutionOrder : 1
Category       : Exporter
Name           : Export-LogicApp.AzCli
Description    : Exports the raw version of the Logic App from the Azure Portal

ExecutionOrder : 2
Category       : Converter
Name           : ConvertTo-LogicApp.Basic
Description    : Converts the raw LogicApp json structure into the a valid LogicApp json,
                 this will remove different properties that are not needed

ExecutionOrder : 3
Category       : Converter
Name           : ConvertTo-Arm
Description    : Converts the LogicApp json structure into a valid ARM template json

.NOTES
General notes
#>
function Get-PsLaTaskOrderByFile {
    [CmdletBinding()]
    param (
        [Alias('BuildFile')]
        [Parameter(Mandatory = $true)]
        [string] $File,

        [switch] $Detailed
    )
    
    # We are playing around with the internal / global psake object
    $psake.context = New-Object System.Collections.Stack

    $default = Get-PSakeScriptTasks -buildFile $File | Where-Object Name -eq "Default" | Select-Object -First 1

    $tasks = @(Get-PSakeScriptTasks -buildFile $File | Where-Object Name -ne "Default" | Select-Object -Property @{Label = "Category"; Expression = { $_.Alias.Split(".")[0] } }, Name, Description)

    $res = @(for ($i = 0; $i -lt $default.DependsOn.Count; $i++) {
            $tasks | Where-Object Name -eq $($default.DependsOn[$i]) | Select-Object -Property @{Label = "ExecutionOrder"; Expression = { $i + 1 } }, *
        })

    if ($Detailed) {
        $res | Format-List
    }
    else {
        $res
    }
}