
<#
    .SYNOPSIS
        Get tasks that are references from a file
        
    .DESCRIPTION
        Get tasks that are references from a runbook file, to make it easier to understand what a given runbook file is doing
        
    .PARAMETER File
        Path to the runbook file, that you want to analyze
        
    .PARAMETER Category
        Used to filter the number of tasks down to only being part of the category that you are looking for
        
    .PARAMETER Detailed
        Instruct the cmdlet to output the details about the tasks in a more detailed fashion, makes it easier to read the descriptions for each task
        
    .EXAMPLE
        PS C:\> Get-PsLaTaskByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1"
        
        List all tasks that are referenced from the file
        The file needs to be a valid PSake runbook file
        
        Output example:
        
        Category  Name                     Description
        --------  ----                     -----------
        Converter ConvertTo-Arm            Converts the LogicApp json structure into a valid ARM template json
        Converter ConvertTo-Raw Converts the raw LogicApp json structure into the a valid LogicApp json,…
        Exporter  Export-LogicApp.AzCli    Exports the raw version of the Logic App from the Azure Portal
        
    .EXAMPLE
        PS C:\> Get-PsLaTaskByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -Category Converter
        
        List all tasks that are referenced from the file, which are in the Converter category
        The file needs to be a valid PSake runbook file
        
        Output example:
        
        Category  Name                     Description
        --------  ----                     -----------
        Converter ConvertTo-Arm            Converts the LogicApp json structure into a valid ARM template json
        Converter ConvertTo-Raw Converts the raw LogicApp json structure into the a valid LogicApp json,…
        
    .EXAMPLE
        PS C:\> Get-PsLaTaskByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -Detailed
        
        List all tasks that are referenced from the file, and outputs it in the detailed view
        The file needs to be a valid PSake runbook file
        
        Output example:
        
        Category    : Converter
        Name        : ConvertTo-Arm
        Description : Converts the LogicApp json structure into a valid ARM template json
        
        Category    : Converter
        Name        : ConvertTo-Raw
        Description : Converts the raw LogicApp json structure into the a valid LogicApp json,
        this will remove different properties that are not needed
        
        Category    : Exporter
        Name        : Export-LogicApp.AzCli
        Description : Exports the raw version of the Logic App from the Azure Portal
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-PsLaTaskByFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [Alias('Runbook')]
        [string] $File,

        [ValidateSet('Arm', 'Converter', 'Exporter', 'LogicApp')]
        [string] $Category,

        [switch] $Detailed
    )
    
    # We are playing around with the internal / global psake object
    $psake.context = New-Object System.Collections.Stack

    $res = @(Get-PSakeScriptTasks -Runbook $File | Where-Object Name -ne "Default" | Select-Object -Property @{Label = "Category"; Expression = { $_.Alias.Split(".")[0] } }, Name, Description)

    $temp = $res | Where-Object Category -like "*$Category*" | Sort-Object Category, Name
        
    if ($Detailed) {
        $temp | Format-List
    }
    else {
        $temp
    }
}