<#
.SYNOPSIS
Get tasks based on files from a directory

.DESCRIPTION
Get tasks from individual files, that are located in a directory

.PARAMETER Path
Path to the directory where there are valid PSake tasks saved as ps1 files

.EXAMPLE
PS C:\> Get-PsLaTaskByPath -Path c:\temp\tasks

List all available tasks, based on the files in the directory
All files has to be valid PSake files saved as ps1 files

Output example:

Category    : Arm
Name        : Set-Arm.Connections.ManagedApis.AsParameter
Description : Loops all $connections childs
              -Creates an Arm parameter, with prefix & suffix
              --Sets the default value to the original name, extracted from connectionId property
              -Sets the connectionId to: [resourceId('Microsoft.Web/connections', parameters('XYZ'))]
              -Sets the connectionName to: [parameters('XYZ')]
Path        : c:\temp\tasks\Set-Arm.Connections.ManagedApis.AsParameter.task.ps1
File        : Set-Arm.Connections.ManagedApis.AsParameter.task.ps1

Category    : Arm
Name        : Set-Arm.Connections.ManagedApis.AsVariable
Description : Loops all $connections childs
              -Creates an Arm variable, with prefix & suffix
              --Sets the value to the original name, extracted from connectionId property
              -Sets the connectionId to: [resourceId('Microsoft.Web/connections', variables('XYZ'))]
              -Sets the connectionName to: [variables('XYZ')]
Path        : c:\temp\tasks\Set-Arm.Connections.ManagedApis.AsVariable.task.ps1
File        : Set-Arm.Connections.ManagedApis.AsVariable.task.ps1

.NOTES
General notes
#>
function Get-PsLaTaskByPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    
    $files = Get-ChildItem -Path "$Path\*.ps1"

    $res = New-Object System.Collections.Generic.List[System.Object]

    # We are playing around with the internal / global psake object
    $psake.context = New-Object System.Collections.Stack
    $psake.context.push(
        @{
            "tasks"   = @{}
            "aliases" = @{}
        }
    )

    foreach ($item in $files) {
        # We are playing around with the internal / global psake object
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
                $res.Add([PsCustomObject][ordered]@{
                        Category    = $value.Alias.Split(".")[0]
                        Name        = $value.Name
                        Description = $value.Description
                        Path        = $item.FullName
                        File        = $item.Name
                    })
            }
        }
    }

    # We are playing around with the internal / global psake object
    $psake.context = New-Object System.Collections.Stack

    $res.ToArray() | Where-Object Name -ne "Default" | Sort-Object Category, Name
}