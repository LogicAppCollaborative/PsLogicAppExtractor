<#
.SYNOPSIS
Set the current working directory

.DESCRIPTION
Sets the current tasks working directory, based on the current PsLaWorkPath and the execution number that task is in the overall execution

Outputs the path that has been constructed

.PARAMETER Path
Path to the current working directory

The value passed in should always be the $PsLaWorkPath, to ensure that things are working

.EXAMPLE
PS C:\> Set-TaskWorkDirectory -Path $PsLaWorkPath

Creates a new sub directory under the $PsLaWorkPath location
The sub directory is named "$Script:TaskCounter_$TaskName"

The output will be: "$PsLaWorkPath\$Script:TaskCounter_$TaskName"

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Set-TaskWorkDirectory {
    [CmdletBinding()]
    param (
        [string] $Path = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.WorkPath),
        
        [string] $FileName = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Pester.FileName)
    )
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value $($(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskCounter) + 1)
    $taskCounter = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskCounter)
    
    # Write-Host "--##Hitting Pester Version##--"

    $taskName = $($psake.context.Peek().CurrentTaskName)
    $newPath = "$Path\$taskCounter`_$TaskName"
    New-Item -Path $newPath -ItemType Directory -Force -ErrorAction Ignore > $null

    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskPath -Value $newPath
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskOutputFile -Value "$newPath\$fileName"
}