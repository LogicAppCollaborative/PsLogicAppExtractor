
# Welcome to the PsLogicAppExtractor project

PsLogicAppExtractor is module designed to make it easier to export valid ARM templates, directly from the Azure portal.

The module is available directly from www.powershellgallery.com to make it easy to get started.

## Purpose
The PsLogicAppExtractor project is deeply inspired by [LogicAppTemplateCreator](https://github.com/jeffhollan/LogicAppTemplateCreator), which [Jeff Hollan](https://twitter.com/jeffhollan) & [Mattias Lögdberg](https://twitter.com/MLogdberg) have been putting amazing efforts into and have made available to for the broader community.

PsLogicAppExtractor offers a different approach to extract a LogicApp, where the module should be considered an orchestration engine, that comes with a lot of tools, and makes it possible for the end user to design their own export orchestration runbook.

The core idea is that a single operation that you want to have applied against your LogicApp while exporting it / converting it to an ARM template is a task. Put in other words, you should view the exporting / converting to an ARM template as a series of micro steps, which breaks down the complexity for building the ARM template. The tradeoff is that you have to orchestrate the steps and their execution sequence, and ones you have done that - you're ready to fully automate things.

The key difference of PsLogicAppExtractor is that it **encourages** the end user to have custom tasks, that handles their specific needs and build a runbook that they can share across their team and that way makes the export process as smooth as possible.

The runbook file can even be included in the source control system, side-by-side with the ARM template - making it easier to update the ARM template, if you need to adjust the LogicApp directly in the portal.azure.com.

## Dependencies
PsLogicAppExtractor is built on top of [PSake](https://github.com/psake/psake), which enables it to act as an orchestration engine. Besides that PSFramework is used to handle some of the configuration details, that you can adjust, to have things working like you want them to.

PSake is want make the execution of different tasks possible, and PSFramework makes it possible to handle things like prefix and suffix configuration across time.

## Example

Below is a complete runbook file and how to execute it. It shows how to do a simple export, and conversion to an ARM template:

**Name:** `Export.ConvertTo-Arm.psakefile.ps1`
```Powershell
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
$listTasks += "Export-LogicApp.AzCli"
$listTasks += "ConvertTo-Raw"
$listTasks += "Set-Raw.ApiVersion"
$listTasks += "ConvertTo-Arm"
    
# Default tasks, the via the dependencies will run all tasks
Task -Name "default" -Depends $listTasks
```

**How to execute:**
```Powershell
Import-Module -Name PsLogicAppExtractor
Invoke-PsLaExtractor -Runbook "C:\temp\Export.ConvertTo-Arm.psakefile.ps1" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"
```

**Output:**
The output is a file, that either lives in the temporary directory under your user account or the supplied output path.

## Getting started
The module includes a few template runbooks, that aids your with getting started and to learn what the module is capable of. From there you can start editing your own runbook and begin to have your own specialized export experience.

When you learn more about the different tasks and how they interact, you can pass a string of task names to `New-PsLaRunbookByTask` and it will build a runbook for you, and from there you can extend it.

### Runbook
Any runbook that you want to use with PsLogicAppExtractor has to be a 100% valid PSake BuildFile, as the execution of all the different tasks are done via PSake.

**Note:**

The module is persisting files on your disk, while it works - so you need to make sure that is acceptable to you and your company.