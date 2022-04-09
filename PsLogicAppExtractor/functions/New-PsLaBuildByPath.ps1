<#
.SYNOPSIS
Create valid build file based on the task files in the directory

.DESCRIPTION
Helps you build a valid build file, based on all the individual task files (ps1) that are located in the directory

This makes it easy to get a starting point for a new build file, based on the tasks you have persisted as individual files

Especially helpful for custom tasks that might be stored in a central repository

The task files has to valid PSake tasks saved as ps1 files

.PARAMETER Path
Path to the directory where there are valid PSake tasks saved as ps1 files

The default value is set for the internal directory where all the generic tasks that are part of the module is located

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
Path to were the build file will be persisted

The path has to be a directory

The build file will be named: PsLaExtractor.default.psakefile.ps1

.PARAMETER IncludePrefixSuffix
Instruct the cmdlet to add the different prefix and suffix options, with the default values that comes with the module

This make it easier to make the build file work across different environments, without having to worry about prepping different prefix and suffix value prior

.EXAMPLE
PS C:\> New-PsLaBuildByPath

Creates a valid build file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes

.EXAMPLE
PS C:\> New-PsLaBuildByPath -Path c:\temp\tasks

Creates a valid build file, based on the bare minimum and with sane default values
Reads all ps1 files located in c:\temp\tasks

Great to use when you have lots of custom tasks in a directory / repository, and want a good build file as starting point

.EXAMPLE
PS C:\> New-PsLaBuildByPath -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg"

Creates a valid build file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
Prepares the Properties object with SubscriptionId and ResourceGroup

Useful if you have multiple logic apps in the same resource group and you want them extracted using the same build file

.EXAMPLE
PS C:\> New-PsLaBuildByPath -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"

Creates a valid build file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
Prepares the Properties object with SubscriptionId and ResourceGroup and Name

Useful if you want to have a ready to run build file, that makes it simple to run the command again and again
Great for iterative work, where you make lots of small changes in the logic app and want to see how the changes affect your ARM template

.EXAMPLE
PS C:\> New-PsLaBuildByPath -OutputPath c:\temp\PsLaBuildfiles

Creates a valid build file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
Outputs the build to c:\temp\PsLaBuildfiles

The build file is default named: PsLaExtractor.default.psakefile.ps1

.EXAMPLE
PS C:\> New-PsLaBuildByPath -IncludePrefixSuffix

Creates a valid build file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
The Properties object inside the build file, will be pre-populated with the default prefix and suffix values from the module

This make it easier to make the build file work across different environments, without having to worry about prepping different prefix and suffix value prior

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function New-PsLaBuildByPath {
    [CmdletBinding()]
    param (
        [string] $Path = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks),

        [string] $SubscriptionId,

        [string] $ResourceGroup,

        [string] $Name,

        [string] $OutputPath,

        [switch] $IncludePrefixSuffix
    )
    


    $files = Get-ChildItem -Path "$Path\*.ps1"

    $res = New-Object System.Collections.Generic.List[System.Object]

    $res.AddRange($(Get-BuildHeader -SubscriptionId $SubscriptionId -ResourceGroup $ResourceGroup -Name $Name -IncludePrefixSuffix:$IncludePrefixSuffix))

    $res.Add("# Path to where the task files are located")
    
    if ($Path -eq $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks)) {
        $res.Add('$pathTasks = $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks)')
    }
    else {
        $res.Add("`$pathTasks = `"$Path`"")
    }
    
    $res.Add("")
    
    $res.Add("# Array to hold all tasks for the default task")
    $res.Add("`$listTasks = @()")

    $res.Add("")

    $includes = New-Object System.Collections.Generic.List[System.Object]
    $list = New-Object System.Collections.Generic.List[System.Object]

    $psake.context = New-Object System.Collections.Stack
    $psake.context.push(
        @{
            "tasks"   = @{}
            "aliases" = @{}
        }
    )

    $found = $false
    foreach ($item in $files) {
        $found = $false

        $psake.context = New-Object System.Collections.Stack
        $psake.context.push(
            @{
                "tasks"   = @{}
                "aliases" = @{}
            }
        )
        
        . $item.FullName

        foreach ($task in $psake.context.tasks) {
            foreach ($value in $task.Values) {
                $found = $true
                $list.Add("`$listTasks += `"$($value.Name)`"")
            }
        }

        if ($found) {
            $includes.Add("Include `"`$pathTasks\$($item.Name)`"")
        }
    }

    $psake.context = New-Object System.Collections.Stack

    #TODO! Make sure that we actually need this - other places it was enough with the $psake.context = New-Object System.Collections.Stack
    # $psake.context.push(
    #     @{
    #         "buildSetupScriptBlock"         = {}
    #         "buildTearDownScriptBlock"      = {}
    #         "taskSetupScriptBlock"          = {}
    #         "taskTearDownScriptBlock"       = {}
    #         "executedTasks"                 = new-object System.Collections.Stack
    #         "callStack"                     = new-object System.Collections.Stack
    #         "originalEnvPath"               = $env:PATH
    #         "originalDirectory"             = get-location
    #         "originalErrorActionPreference" = $global:ErrorActionPreference
    #         "tasks"                         = @{}
    #         "aliases"                       = @{}
    #         "properties"                    = new-object System.Collections.Stack
    #         "includes"                      = new-object System.Collections.Queue
    #     }
    # )
    
    $res.Add("# All tasks that needs to be include based on their path")
    $res.AddRange($includes)
    $res.Add("")
    $res.Add("# Building the list of tasks for the default task")
    $res.AddRange($list)
    $res.Add("")
    $res.Add("# Default tasks, the via the dependencies will run all tasks")
    $res.Add("Task -Name `"default`" -Depends `$listTasks")
 
    if ($OutputPath) {
        New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction Ignore > $null

        $path = Join-Path -Path $OutputPath -ChildPath "PsLaExtractor.default.psakefile.ps1"

        $encoding = [PSFEncoding]'utf8'
        [System.IO.File]::WriteAllLines($path, $Content, $encoding)

        Get-Item -Path $path
    }
    else {
        $res.ToArray() -join "`r`n"
    }
}