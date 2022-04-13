# Object to store the needed parameters for when running the export
Properties {
    $SubscriptionId = $null
    $ResourceGroup = $null
    $Name = ""
    $ApiVersion = "2019-05-01"
}
    
# Used to import the needed classes into the powershell session, to help with the export of the Logic App
."$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes)\PsLogicAppExtractor.class.ps1"
    
# Path to where the task files are located
$pathTasks = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks)
    
# Array to hold all tasks for the default task
$listTasks = @()
    
# All tasks that needs to be include based on their path
Include "$pathTasks\Export-LogicApp.AzCli.task.ps1"
Include "$pathTasks\ConvertTo-Raw.task.ps1"
Include "$pathTasks\Set-Raw.ApiVersion.task.ps1"
Include "$pathTasks\ConvertTo-Arm.task.ps1"
    
# Building the list of tasks for the default task
$listTasks += "Export-LogicApp.AzCli"
$listTasks += "ConvertTo-Raw"
$listTasks += "Set-Raw.ApiVersion"
$listTasks += "ConvertTo-Arm"
    
# Default tasks, the via the dependencies will run all tasks
Task -Name "default" -Depends $listTasks