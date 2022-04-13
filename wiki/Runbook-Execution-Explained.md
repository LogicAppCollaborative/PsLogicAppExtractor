## Execution of a runbook

Everything starts with a runbook, which is a valid PSake BuildFile. An brief example looks like this:

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

Explaining all the finer details are out of scope for this wiki, if you want to learn more about what PSake can do and what the different things solve, please read more [here](https://adamtheautomator.com/powershell-psake/)

The different Include statements, allows the runbook to reference tasks that exists in separate files. This allows for sharing tasks across different runbooks, which PsLogicAppExtractor is also depending on, by having all its tasks stored in single files and importing them via the Include statements.
The Include statement only **enables** the usage of a given task - it doesn't dictate whether or not it will be run.

The default task, which get decorated with an array of tasks it depends on, is what enables the execution of tasks in sequence. The `$listTasks` is where you want to put all you attention to, in terms of creating the perfect execution of the different tasks.

`Invoke-PsLaExtractor` is the start point of the orchestration of prepare the export of the LogicApp, at some point call `Invoke-psake` and from there the tasks are executed in the context of PSake. Because the context actually shifts, we need to have all the "magic" code bits as part of our runbook.

While the runbook runs, each single task, creates a sub-directory under the workpath, the default path is the temporary directory under the executing user account. Each tasks implements some default code, which enables PsLogicAppExtractor to keep track of what step a given task was executed in the entire sequence. This makes it easier to troubleshoot an export that didn't produce the expected output.

The output structure from the above run would like this:

[[images/RunbookExecution-001.png]]

As explained, the sequence in which the tasks are inside the `$listTasks`, dictates the execution order of the tasks. Each task gets a sub-directory, prefixed with the execution / step number, and then the name of the task. Inside each sub-directory, are the input file for the task located as well as the persisted output. All files and sub-directories are deleted after the execution - expect for the final output file (if the output parameter wasn't supplied).

**Note:**

The module is persisting files on your disk, while it works - so you need to make sure that is acceptable to you and your company.