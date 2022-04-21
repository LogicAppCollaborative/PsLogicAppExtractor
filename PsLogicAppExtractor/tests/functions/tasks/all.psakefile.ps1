﻿# Object to store the needed parameters for when running the export
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
Include "$pathTasks\ConvertTo-Arm.task.ps1"
Include "$pathTasks\ConvertTo-Raw.task.ps1"
Include "$pathTasks\Export-LogicApp.AzCli.task.ps1"
Include "$pathTasks\Export-Raw.ManagedApis.DisplayName.AzAccount.task.ps1"
Include "$pathTasks\Export-Raw.ManagedApis.DisplayName.AzCli.task.ps1"
# Include "$pathTasks\Initialize.task.ps1"
Include "$pathTasks\Set-Arm.Connections.ManagedApis.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.Connections.ManagedApis.AsVariable.task.ps1"
Include "$pathTasks\Set-Arm.Connections.ManagedApis.IdFormatted.task.ps1"
Include "$pathTasks\Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsVariable.task.ps1"
Include "$pathTasks\Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.IntegrationAccount.IdFormatted.Simple.AsVariable.task.ps1"
Include "$pathTasks\Set-Arm.Location.AsResourceGroup.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.LogicApp.Name.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.LogicApp.Parm.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.LogicApp.Parm.AsVariable.task.ps1"
Include "$pathTasks\Set-Arm.Tags.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.Tags.AsVariable.task.ps1"
Include "$pathTasks\Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.Trigger.ApiConnection.evaluatedRecurrence.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.Trigger.Cds.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.UserAssignedIdentities.ResourceId.AsParameter.task.ps1"
Include "$pathTasks\Set-Arm.UserAssignedIdentities.ResourceId.AsVariable.task.ps1"
Include "$pathTasks\Set-Raw.Actions.Http.Audience.AsParm.task.ps1"
Include "$pathTasks\Set-Raw.Actions.Http.Uri.AsParm.task.ps1"
Include "$pathTasks\Set-Raw.Actions.Servicebus.Queue.AsParm.task.ps1"
Include "$pathTasks\Set-Raw.ApiVersion.task.ps1"
Include "$pathTasks\Set-Raw.Connections.ManagedApis.Name.task.ps1"
Include "$pathTasks\Set-Raw.Connections.ManagedApis.Id.task.ps1"
Include "$pathTasks\Set-Raw.State.Disabled.task.ps1"
Include "$pathTasks\Set-Raw.State.Enabled.task.ps1"
Include "$pathTasks\Set-Raw.Trigger.Servicebus.Queue.AsParm.task.ps1"
Include "$pathTasks\Set-Raw.UserAssignedIdentities.EmptyValue.task.ps1"
Include "$pathTasks\Sort-Raw.LogicApp.Tag.task.ps1"
Include "$pathTasks\Sort-Arm.Parameter.task.ps1"
Include "$pathTasks\Sort-Raw.LogicApp.Parm.task.ps1"
Include "$pathTasks\Sort-Arm.Variable.task.ps1"
    
# Building the list of tasks for the default task
$listTasks += "ConvertTo-Arm"
$listTasks += "ConvertTo-Raw"
$listTasks += "Export-LogicApp.AzCli"
$listTasks += "Export-Raw.ManagedApis.DisplayName.AzAccount.task"
$listTasks += "Export-Raw.ManagedApis.DisplayName.AzCli.task"
# $listTasks += "Initialize"
$listTasks += "Set-Arm.Connections.ManagedApis.AsParameter"
$listTasks += "Set-Arm.Connections.ManagedApis.AsVariable"
$listTasks += "Set-Arm.Connections.ManagedApis.IdFormatted"
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