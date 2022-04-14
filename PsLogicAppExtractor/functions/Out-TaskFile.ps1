
<#
    .SYNOPSIS
        Output the tasks result to a file
        
    .DESCRIPTION
        Persists the tasks output into a file, either the raw content or the object
        
        Sets the $Script:FilePath = $Path, to ensure the next tasks can pick up the file and continue its work
        
    .PARAMETER Path
        Path to where the tasks wants the ouput to be persisted
        
    .PARAMETER Content
        Raw string that should be written to the desired path
        
    .PARAMETER InputObject
        The object that should be written to the desired path
        
        Will be converted to a json string, usign the ConvertTo-Json
        
        Important note: If you need the InputObject to be written with a specific structure, the object has to be of the expected type before being passed into the cmdlet
        A simple cast can ensure this to work as intended
        
    .EXAMPLE
        PS C:\> Out-TaskFile -Path "C:\temp\work_directory\1_Export-LogicApp.AzCli" -InputObject $([ArmTemplate]$armObj)
        
        Outputs the armObj variable to the path: "C:\temp\work_directory\1_Export-LogicApp.AzCli"
        The armObj is casted to the [ArmTemplate] type, to ensure it is persisted as the expected json structure
        
    .EXAMPLE
        PS C:\> Out-TaskFile -Path "C:\temp\work_directory\1_Export-LogicApp.AzCli" -Content '{"Test":"Test"}'
        
        Outputs the content string: '{"Test":"Test"}' to the path: "C:\temp\work_directory\1_Export-LogicApp.AzCli"
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Out-TaskFile {
    [CmdletBinding(DefaultParameterSetName = "InputObject")]
    param (
        [string] $Path = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskOutputFile),

        [Parameter(Mandatory = $true, ParameterSetName = "Content")]
        [string] $Content,

        [Parameter(Mandatory = $true, ParameterSetName = "InputObject")]
        [object] $InputObject
    )
    
    if ($InputObject) {
        $Content = $InputObject | ConvertTo-Json -Depth 20
    }

    $encoding = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllLines($Path, $Content, $encoding)
    
    if ($(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskInputNext)) {
        $taskPath = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskPath
        Copy-Item -Path $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskInputNext) -Destination "$taskPath\Input.json"
    }

    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value $Path
}