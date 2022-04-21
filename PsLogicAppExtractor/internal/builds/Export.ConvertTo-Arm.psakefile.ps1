# Object to store the needed parameters for when running the export
Properties {
    $SubscriptionId = $null
    $ResourceGroup = $null
    $Name = ""
    $ApiVersion = "2019-05-01"
}

# Used to import the needed classes into the powershell session, to help with the export of the Logic App
."$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes)\PsLogicAppExtractor.class.ps1"

# Path variable for all the tasks that is available from the PsLogicAppExtractor module
$pathTasks = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks)

# Include all the tasks that is available from the PsLogicAppExtractor module
Include "$pathTasks\All\All.task.ps1"

# Array to hold all tasks for the default task
$listTasks = @()
    
# Building the list of tasks for the default task

#Pick ONE of these two
$listTasks += "Export-LogicApp.AzCli"
# $listTasks += "Export-LogicApp.AzAccount"

$listTasks += "ConvertTo-Raw"
$listTasks += "Set-Raw.ApiVersion"
$listTasks += "ConvertTo-Arm"
    
# Default tasks, the via the dependencies will run all tasks
Task -Name "default" -Depends $listTasks