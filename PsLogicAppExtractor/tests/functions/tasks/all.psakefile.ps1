# Object to store the needed parameters for when running the export
Properties {
    $SubscriptionId = $null
    $ResourceGroup = $null
    $Name = "ChangeThis"
    $ApiVersion = "2019-05-01"
}
    
# Used to import the needed classes into the powershell session, to help with the export of the Logic App
."$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes)\PsLogicAppExtractor.class.ps1"
    
Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0

# Path to where the task files are located
$pathTasks = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks)
    
# Array to hold all tasks for the default task
$listTasks = @()

# All tasks that needs to be include based on their path
Include "$pathTasks\All\All.task.ps1"
    
# Building the list of tasks for the default task
$listTasks += "ConvertTo-Arm"
$listTasks += "ConvertTo-Raw"
$listTasks += "Export-LogicApp.AzCli"
$listTasks += "Export-Raw.Connections.ManagedApis.DisplayName.AzAccount.task"
$listTasks += "Export-Raw.Connections.ManagedApis.DisplayName.AzCli.task"
# $listTasks += "Initialize"
$listTasks += "Set-Arm.Connections.ManagedApis.AsParameter"
$listTasks += "Set-Arm.Connections.ManagedApis.AsVariable"
$listTasks += "Set-Arm.Connections.ManagedApis.IdFormatted"
$listTasks += "Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject"
$listTasks += "Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject"
$listTasks += "Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter.AsVariable"
$listTasks += "Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsParameter.AsVariable"
$listTasks += "Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsParameter"
$listTasks += "Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter"
$listTasks += "Set-Arm.Location.AsResourceGroup.AsParameter"
$listTasks += "Set-Arm.LogicApp.Name.AsParameter"
$listTasks += "Set-Arm.LogicApp.Parm.AsParameter"
$listTasks += "Set-Arm.LogicApp.Parm.AsVariable"
$listTasks += "Set-Arm.Tags.AsParameter"
$listTasks += "Set-Arm.Tags.AsVariable"
$listTasks += "Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter"
$listTasks += "Set-Arm.Trigger.ApiConnection.evaluatedRecurrence.AsParameter"
$listTasks += "Set-Arm.Trigger.Cds.AsParameter"
$listTasks += "Set-Arm.UserAssignedIdentities.ResourceId.AsParameter"
$listTasks += "Set-Arm.UserAssignedIdentities.ResourceId.AsVariable"
$listTasks += "Set-Raw.Actions.Http.Audience.AsParm"
$listTasks += "Set-Raw.Actions.Http.Uri.AsParm"
$listTasks += "Set-Raw.Actions.Servicebus.Queue.AsParm"
$listTasks += "Set-Raw.ApiVersion"
$listTasks += "Set-Raw.Connections.ManagedApis.Name"
$listTasks += "Set-Raw.Connections.ManagedApis.Id"
$listTasks += "Set-Raw.State.Disabled"
$listTasks += "Set-Raw.State.Enabled"
$listTasks += "Set-Raw.Trigger.Servicebus.Queue.AsParm"
$listTasks += "Set-Raw.UserAssignedIdentities.EmptyValue"
$listTasks += "Sort-Arm.Parameter"
$listTasks += "Sort-Arm.Variable"
$listTasks += "Sort-Raw.LogicApp.Parm"
$listTasks += "Sort-Raw.LogicApp.Tag"
    
# Default tasks, the via the dependencies will run all tasks
Task -Name "default" -Depends $listTasks