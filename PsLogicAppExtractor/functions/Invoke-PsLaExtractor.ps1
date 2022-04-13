
<#
    .SYNOPSIS
        Execute the extractor process of the LogicApp
        
    .DESCRIPTION
        Execute all the tasks that have been defined in the runbook file, and get an ARM template as output
        
        Depending on the initial extractor task that you are using, your powershell / az cli session needs to be signed in
        
        Your runbook file can contain the tasks available from the module, but also your own custom tasks, that you want to have executed as part of the process
        
    .PARAMETER Runbook
        Path to the PSake valid runbook file that you want to have executed while exporting, sanitizing and converting a LogicApp into a deployable ARM template
        
    .PARAMETER SubscriptionId
        Id of the subscription that you want to work against, your current powershell / az cli session either needs to "connected" to the subscription or at least have permissions to work against the subscription
        
    .PARAMETER ResourceGroup
        Name of the resource group that you want to work against, your current powershell / az cli session needs to have permissions to work against the resource group
        
    .PARAMETER Name
        Name of the logic app, that you want to work against
        
    .PARAMETER Task
        List of task that you want to have executed, based on the runbook file that you pass
        
        This allows you to only run a small subset of all the tasks that you have defined inside your runbook
        
        Helpful when troubleshooting and trying to identify the best execution order of all the tasks
        
    .PARAMETER WorkPath
        Path to were the tasks will persist their outputs
        
        Each task will save a file into a unique folder, containing the formatted output from its operation
        
        You could risk that secrets or credentials are being stored on your disk, if they in some way are stored as clear text inside the logic app
        
        The default valus is the current users TempPath, where it creates a "\PsLogicAppExtractor\GUID\" directory for each invoke
        
    .PARAMETER OutputPath
        Path to were the ARM template file will be persisted
        
        The path has to be a directory
        
        The file will be named as the Logic App is named
        
    .PARAMETER KeepFiles
        Instruct the cmdlet to keep all the files, across all tasks
        
        This enables troubleshooting and comparison of input vs output, per task, as each task has an input file and the result of the work persisted in the same directory
        
    .EXAMPLE
        PS C:\> Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp
        
        Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
        The file needs to be a valid PSake runbook file
        
    .EXAMPLE
        PS C:\> Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"
        
        Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
        The file needs to be a valid PSake runbook file
        
    .EXAMPLE
        PS C:\> Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1"
        
        Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
        The file needs to be a valid PSake runbook file
        The runbook file needs to have populated the Properties object, with the minimum: ResourceGroup and SubscriptionId
        
    .EXAMPLE
        PS C:\> Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp -WorkPath "C:\temp\work_directory"
        
        Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
        The file needs to be a valid PSake runbook file
        Will output all tasks files into the "C:\temp\work_directory" location
        
    .EXAMPLE
        PS C:\> Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp -KeepFiles
        
        Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
        The file needs to be a valid PSake runbook file
        All files that the different tasks has created, are keept, for the user to analyze them
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Invoke-PsLaExtractor {
    [CmdletBinding(DefaultParameterSetName = "NameOnly")]
    param (
        [Alias('File')]
        [Parameter(Mandatory = $true, ParameterSetName = "NameOnly")]
        [Parameter(Mandatory = $true, ParameterSetName = "PreppedFile")]
        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $Runbook,

        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $ResourceGroup,

        [Parameter(Mandatory = $true, ParameterSetName = "NameOnly")]
        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $Name,

        [string[]] $Task,

        [string] $WorkPath = "$([System.IO.Path]::GetTempPath())PsLogicAppExtractor\$([System.Guid]::NewGuid().Guid)",

        [string] $OutputPath,

        [switch] $KeepFiles
    )

    if (-not ($WorkPath -like "*$([System.IO.Path]::GetTempPath())*")) {
        if ($WorkPath -NotMatch '(?im)[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?') {
            $WorkPath = "$WorkPath\$([System.Guid]::NewGuid().Guid)"
        }
    }

    #The task counter needs to be reset prior running
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0

    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value ""
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskOutputFile -Value ""
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskPath -Value ""

    #Make sure the work path is created and available
    New-Item -Path $WorkPath -ItemType Directory -Force -ErrorAction Ignore > $null

    $parms = @{}
    $parms.buildFile = $Runbook
    $parms.nologo = $true

    if ($Task) {
        $parms.taskList = $Task
    }
    
    $props = @{}
    if ($SubscriptionId) { $props.SubscriptionId = $SubscriptionId }
    if ($ResourceGroup) { $props.ResourceGroup = $ResourceGroup }
    if ($Name) {
        $props.Name = $Name
    }

    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.WorkPath -Value $WorkPath

    $res = Invoke-psake @parms -properties $props -ErrorVariable errorsFound
    
    if ($errorsFound) {
        throw $res
    }

    $resPath = Get-ExtractOutput -Path $WorkPath

    if ($OutputPath) {
        $resPath = Copy-Item -Path $resPath -Destination "$OutputPath" -PassThru -Force | Select-Object -ExpandProperty FullName
    }

    $resPath

    if (-not $KeepFiles) {
        Get-ChildItem -Path $WorkPath -File -Recurse | Where-Object { $_.FullName -ne $resPath } | ForEach-Object { Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue -Confirm:$false -Recurse }
        Get-ChildItem -Path $WorkPath -Directory | Where-Object { $_.FullName -ne $(Split-Path -Path $resPath -Parent) } | ForEach-Object { Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue -Confirm:$false -Recurse }
    }
}