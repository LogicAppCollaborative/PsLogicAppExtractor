## Structure of a Task

A task is a PSake object, and a basic task looks like this:

```Powershell
Task -Name "SuperTask" -Action {
}
```

For a task to be a "valid" PsLogicAppExtractor task, it needs a few things more than a basic task:

**File:** `Set-Raw.ApiVersion.task.ps1`
```Powershell
$parm = @{
    Description = @"
Creates / assigns the ApiVersion property in the LogicApp json structure
-Sets the value to: `$ApiVersion (property passed as argument)
"@
    Alias       = "Raw.Set-Raw.ApiVersion"
}

Task -Name "Set-Raw.ApiVersion" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    $lgObj.apiVersion = $ApiVersion

    Out-TaskFileLogicApp -InputObject $lgObj
}
```

The `parm` object (hashtable), is used to make a high level explanation (`Description`), that explains what the tasks does. Keep it as short as possible, but include enough so users don't have to open the task and view the code inside the task, to understand what it does. The `Alias` property is hi-jacked (for now) to enable the support for basic metadata on a task. The string prior the first dot is translated into the Category value that you will see when looking at tasks with `Get-PsLaTask`, `Get-PsLaTaskByFile` and `Get-PsLaTaskOrderByFile`.

To help keeping track of what step a given task was in the execution, and persisting the output from the task, the `Set-TaskWorkDirectory` cmdlet is the hero of the day. It increments a internal counter, creates a sub-directory for the current task and updates internal variables.

To get an object that you can work against in your task, you depend on the `Get-TaskWorkObject` cmdlet. It reads persisted output, from the **previous** task, and returns a PsCustomObject. It will either by of the `[ArmTemplate]` or `[LogicApp]` types, `[ArmTemplate]` will represent a valid ARM template, with the LogicApp definition as an inner object, while `[LogicApp]` is the raw LogicApp object.

In the beginning it can be a bit confusing to understand when it makes sense to work with an `[ArmTemplate]` vs `[LogicApp]` object, but it starts to make sense when you start to design your runbook execution.

Between the `Get-TaskWorkObject` cmdlet and the `Out-TaskFileLogicApp` your code has to be placed. We recommend to adapt to a [idempotency](https://en.wikipedia.org/wiki/Idempotence) approach - simply put: Make sure the code can run multiple times and don't break anything. You can read more on the overall concept here: (https://nordicapis.com/understanding-idempotency-and-safety-in-api-design/)

**Note:**

We also recommend that you have a safe-guard approach for the work the tasks should complete: Make sure that the thing you want to change/edit/manipulate in fact is present in the object. If not - just skip running your code and let the next tasks complete its work. Consider to test if you expected changes already implemented - so you can skip running your code - otherwise you risk ending up with a broken state.

When all you work is completed, you invoke the `Out-TaskFileArm` or `Out-TaskFileLogicApp` cmdlet, and pass the object to it. This will persist the output as a file in the sub-directory created just for this task, and update the internal variables, for the next task to pick up.

So to utilize the PsLogicAppExtractor, you will need to respect / utilize the few magic lines of code - but gain that the only true limitation of the module is your own capabilities to write code that solve your specific use case.