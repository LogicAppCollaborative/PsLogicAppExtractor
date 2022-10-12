<#
.SYNOPSIS
Split an ARM template into multiple files, based on the resource type

.DESCRIPTION
You might have a large ARM template, consisting of multiple resource types. This script will create single ARM templates for the specified resource type, and will copy the parameters from the original template

.PARAMETER Path
Path to the ARM template that you want to work against

.PARAMETER OutputPath
Path to were the ARM template file will be persisted
        
The path has to be a directory
        
The file will be named as the original ARM template file

.PARAMETER TypeFilter
Instruct the cmdlet to only process the specified resource type

The default value is 'Microsoft.Web/connections'

.EXAMPLE
PS C:\> Split-ArmTemplate -Path 'C:\temp\template.json' -OutputPath 'C:\temp\output'

This will create a new ARM template file for each resource of the type 'Microsoft.Web/connections' in the original ARM template file.
The new ARM template files will be persisted in the 'C:\temp\output' directory.

.EXAMPLE
PS C:\> Split-ArmTemplate -Path 'C:\temp\template.json'

This will create a new ARM template file for each resource of the type 'Microsoft.Web/connections' in the original ARM template file.
The new ARM template files will be persisted in the same directory as the original ARM template file.

.EXAMPLE
PS C:\> Split-ArmTemplate -Path 'C:\temp\template.json' -TypeFilter 'Microsoft.Web/sites'

This will create a new ARM template file for each resource of the type 'Microsoft.Web/sites' in the original ARM template file.
The new ARM template files will be persisted in the same directory as the original ARM template file.

.NOTES
Author: Mötz Jensen (@Splaxi)
#>
function Split-PsLaArmTemplate {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [Alias('File')]
        [string] $Path,

        [PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
        [string] $OutputPath,

        [Alias('ResourceType')]
        [string] $TypeFilter = 'Microsoft.Web/connections'
    )

    if (-not $OutputPath) {
        $OutputPath = Split-Path -Path $Path -Parent
    }

    # #Make sure the output path is created and available
    New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction Ignore > $null

    #The task counter needs to be reset prior running
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0

    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value ""
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskOutputFile -Value ""
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskPath -Value ""
    Set-PSFConfig -FullName PsLogicAppExtractor.Execution.Name -Value ""
            
    $InputObject = Get-TaskWorkObject -Path $Path

    # We only want to process the resources that are of the type we are looking for
    $colFiltered = $InputObject.resources | Where-Object { $_.type -eq $TypeFilter }

    $baseName = Split-Path -Path $Path -LeafBase
    for ($i = 0; $i -lt $colFiltered.Count; $i++) {
        $Destination = Join-Path -Path $OutputPath -ChildPath "$baseName`__$(($i+1).ToString().PadLeft(3, "0")).json"
        $obj = $colFiltered[$i]

        # Loading the original ARM template file, but to be used for the local resource
        $tempArm = Get-TaskWorkObject -Path $Path

        # The resources is overwritten with the resource we are currently processing
        $tempArm.resources = @($obj)

        # We need to do some string manipulation to get the names of the parameters
        $jsonStr = $obj | ConvertTo-Json -Depth 100

        # We need to match all parameters that are used in the resource
        $parmsToKeep = @(($jsonStr | Select-String  "parameters\('(.*?)'\)" -AllMatches).Matches.Groups | Where-Object { $null -eq $_.Groups } | Select-Object -ExpandProperty Value -Unique)

        # We need to remove all parameters that are not used in the resource
        $tempArm.Parameters.PsObject.Properties | Where-Object { $parmsToKeep -notcontains $_.Name } | Select-Object -ExpandProperty Name | ForEach-Object {
            $tempArm = Remove-ArmParameter -InputObject $tempArm -Name $_
        }

        Out-TaskFile -Path $Destination -InputObject $tempArm
    }
}