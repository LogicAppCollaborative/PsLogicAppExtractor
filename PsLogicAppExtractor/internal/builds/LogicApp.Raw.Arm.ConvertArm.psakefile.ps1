# Object to store the needed parameters for when running the export
Properties {
    $SubscriptionId = $null
    $ResourceGroup = $null
    $Name = "ChangeThis"
    $ApiVersion = "2019-05-01"
    $PsLaWorkPath = ""
}
    
# Used to import the needed classes into the powershell session, to help with the export of the Logic App
."$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes)\PsLogicAppExtractor.class.ps1"
    
# Path to where the task files are located
$pathTasks = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks)
    
# Array to hold all tasks for the default task
$listTasks = @()
    
# All tasks that needs to be include based on their path
Include "$pathTasks\Export-LogicApp.AzCli.task.ps1"
Include "$pathTasks\ConvertTo-LogicAppToBasic.task.ps1"
Include "$pathTasks\Set-RawApiVersion.task.ps1"
Include "$pathTasks\Set-RawStateEnabled.task.ps1"
Include "$pathTasks\Set-RawUserAssignedIdentity.EmptyValue.task.ps1"
Include "$pathTasks\Set-RawConnectionName.task.ps1"
# Include "$pathTasks\Set-RawActions.Http.Uri.AsParm.task.ps1"
# Include "$pathTasks\Set-RawActions.Http.Audience.AsParm.task.ps1"
Include "$pathTasks\Set-RawActions.Servicebus.Queue.AsParm.task.ps1"
Include "$pathTasks\Set-RawTrigger.Servicebus.Queue.AsParm.task.ps1"

Include "$pathTasks\ConvertTo-Arm.task.ps1"
    
Include "$pathTasks\Set-ArmTrigger.ApiConnection.Recurrence.AsParameter.task.ps1"
Include "$pathTasks\Set-ArmTrigger.Cds.AsParameter.task.ps1"

Include "$pathTasks\Set-ArmLocationResourceGroup.AsParameter.task.ps1"
Include "$pathTasks\Set-ArmName.AsParameter.task.ps1"

Include "$pathTasks\Set-ArmLogicAppParm.AsParameter.task.ps1"

Include "$pathTasks\Set-ArmManagedApisConnectionIdFormatted.task.ps1"
Include "$pathTasks\Set-ArmManagedApisConnection.AsParameter.task.ps1"

Include "$pathTasks\Set-ArmUserAssignedIdentitiesResourceId.AsParameter.task.ps1"

Include "$pathTasks\Set-ArmIntegrationAccountIdFormatted.Simple.task.ps1"
# Include "$pathTasks\Set-ArmIntegrationAccountIdFormatted.Advanced.task.ps1"

Include "$pathTasks\Set-ArmTags.AsParameter.task.ps1"
Include "$pathTasks\Set-ArmParameterSort.task.ps1"


# Building the list of tasks for the default task
$listTasks += "Export-LogicApp.AzCli"
$listTasks += "ConvertTo-LogicAppToBasic"
$listTasks += "Set-RawApiVersion"
$listTasks += "Set-RawStateEnabled"
$listTasks += "Set-RawUserAssignedIdentity.EmptyValue"
$listTasks += "Set-RawConnectionName"
# $listTasks += "Set-RawActions.Http.Uri.AsParm"
# $listTasks += "Set-RawActions.Http.Audience.AsParm"
$listTasks += "Set-RawActions.Servicebus.Queue.AsParm"
$listTasks += "Set-RawTrigger.Servicebus.Queue.AsParm"

$listTasks += "ConvertTo-Arm"
    
$listTasks += "Set-ArmTrigger.ApiConnection.Recurrence.AsParameter"
$listTasks += "Set-ArmTrigger.Cds.AsParameter"

$listTasks += "Set-ArmLocationResourceGroup.AsParameter"
$listTasks += "Set-ArmName.AsParameter"

$listTasks += "Set-ArmLogicAppParm.AsParameter"

$listTasks += "Set-ArmManagedApisConnectionIdFormatted"
$listTasks += "Set-ArmManagedApisConnection.AsParameter"

$listTasks += "Set-ArmUserAssignedIdentitiesResourceId.AsParameter"

$listTasks += "Set-ArmIntegrationAccountIdFormatted.Simple"
# $listTasks += "Set-ArmIntegrationAccountIdFormatted.Advanced"

$listTasks += "Set-ArmTags.AsParameter"
$listTasks += "Set-ArmParameterSort"

# Default tasks, the via the dependencies will run all tasks
Task -Name "default" -Depends $listTasks