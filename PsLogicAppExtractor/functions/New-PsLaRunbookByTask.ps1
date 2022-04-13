<#
.SYNOPSIS
Create valid runbook file based on the task passed as inputs

.DESCRIPTION
Helps you build a valid runbook file, based on all the individual tasks that are passed as inputs

This makes it easy to get a starting point for a new runbook file, based on the tasks you have build in your array and then passes into the cmdlet

Tasks are expected to be the ones that are part of the module

.PARAMETER Task
Names of the tasks that you want to be part of your runbook file

Supports array of task names

Names of the different tasks are expected to be the ones that are part of the module

.PARAMETER SubscriptionId
Id of the subscription that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session either needs to "connected" to the subscription or at least have permissions to work against the subscription

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

.PARAMETER ResourceGroup
Name of the resource group that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session needs to have permissions to work against the resource group

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

.PARAMETER Name
Name of the logic app, that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session needs to have permissions to work against the logic app

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

.PARAMETER OutputPath
Path to were the runbook file will be persisted

The path has to be a directory

The runbook file will be named: PsLaExtractor.default.psakefile.ps1

.PARAMETER IncludePrefixSuffix
Instruct the cmdlet to add the different prefix and suffix options, with the default values that comes with the module

This make it easier to make the runbook file work across different environments, without having to worry about prepping different prefix and suffix value prior

.EXAMPLE
PS C:\> New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm"

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks

.EXAMPLE
PS C:\> New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg"

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
Prepares the Properties object with SubscriptionId and ResourceGroup

Useful if you have multiple logic apps in the same resource group and you want them extracted using the same runbook file

.EXAMPLE
PS C:\> New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
Prepares the Properties object with SubscriptionId and ResourceGroup and Name

Useful if you want to have a ready to run runbook file, that makes it simple to run the command again and again
Great for iterative work, where you make lots of small changes in the logic app and want to see how the changes affect your ARM template

.EXAMPLE
PS C:\> New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -OutputPath c:\temp\PsLaRunbooks

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
Outputs the build to c:\temp\PsLaRunbooks

The runbook file is default named: PsLaExtractor.default.psakefile.ps1

.EXAMPLE
PS C:\> New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -IncludePrefixSuffix

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
The Properties object inside the runbook file, will be pre-populated with the default prefix and suffix values from the module

This make it easier to make the runbook file work across different environments, without having to worry about prepping different prefix and suffix value prior

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function New-PsLaRunbookByTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]] $Task,
        
        [string] $SubscriptionId,

        [string] $ResourceGroup,

        [string] $Name,

        [string] $OutputPath,

        [switch] $IncludePrefixSuffix
    )
    
    $res = New-Object System.Collections.Generic.List[System.Object]

    $res.AddRange($(Get-BuildHeader -SubscriptionId $SubscriptionId -ResourceGroup $ResourceGroup -Name $Name -IncludePrefixSuffix:$IncludePrefixSuffix))

    $res.Add("# Array to hold all tasks for the default task")
    $res.Add('$listTasks = @()')

    $res.Add('')

    $list = New-Object System.Collections.Generic.List[System.Object]
    
    foreach ($item in $Task) {
        $list.Add("`$listTasks += `"$item`"")
    }

    $res.AddRange($list)
    $res.Add("")
    $res.Add("# Default tasks, the via the dependencies will run all tasks")
    $res.Add('Task -Name "default" -Depends $listTasks')
    
    if ($OutputPath) {
        New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction Ignore > $null

        $path = Join-Path -Path $OutputPath -ChildPath "PsLaExtractor.default.psakefile.ps1"

        $encoding = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllLines($path, $($res.ToArray() -join "`r`n"), $encoding)

        Get-Item -Path $path | Select-Object -ExpandProperty FullName
    }
    else {
        $res.ToArray() -join "`r`n"
    }
}