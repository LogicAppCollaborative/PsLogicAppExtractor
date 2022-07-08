
<#
    .SYNOPSIS
        Get parameters from ARM template
        
    .DESCRIPTION
        Get parameters from the ARM template
        
        You can include / exclude parameters, so your parameter file only contains the parameters you want to handle at deployment
        
        The default value is promoted as the initial value of the parameter
        
    .PARAMETER Path
        Path to the ARM template that you want to work against
        
    .PARAMETER Exclude
        Instruct the cmdlet to exclude the given set of parameter names
        
        Supports array / list
        
    .PARAMETER Include
        Instruct the cmdlet to include the given set of parameter names
        
        Supports array / list
        
    .PARAMETER AsFile
        Instruct the cmdlet to save a valid ARM template parameter file next to the ARM template file
        
    .PARAMETER BlankValues
        Instructs the cmdlet to blank the values in the parameter file
        
    .PARAMETER CopyMetadata
        Instructs the cmdlet to copy over the metadata property from the original parameter in the ARM template, if present
        
    .EXAMPLE
        PS C:\> Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json"
        
        Gets all parameters from the "TestLogicApp.json" ARM template
        The output is written to the console
        
    .EXAMPLE
        PS C:\> Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -Exclude "logicAppLocation","trigger_Frequency"
        
        Gets all parameters from the "TestLogicApp.json" ARM template
        Will exclude the parameters "logicAppLocation" & "trigger_Frequency" if present
        The output is written to the console
        
    .EXAMPLE
        PS C:\> Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -Include "trigger_Interval","trigger_Frequency"
        
        Gets all parameters from the "TestLogicApp.json" ARM template
        Will only copy over the parameters "trigger_Interval" & "trigger_Frequency" if present
        The output is written to the console
        
    .EXAMPLE
        PS C:\> Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -AsFile
        
        Gets all parameters from the "TestLogicApp.json" ARM template
        The output is written the "C:\temp\work_directory\TestLogicApp.parameters.json" file
        
    .EXAMPLE
        PS C:\> Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -BlankValues
        
        Gets all parameters from the "TestLogicApp.json" ARM template
        Blank all values for each parameter
        The output is written to the console
        
    .EXAMPLE
        PS C:\> Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -CopyMetadata
        
        Gets all parameters from the "TestLogicApp.json" ARM template
        Copies over the metadata property from the original parameter, if present
        The output is written to the console
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-PsLaArmParameter {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [string] $Path,

        [string[]] $Exclude,

        [string[]] $Include,

        [switch] $AsFile,

        [switch] $BlankValues,

        [switch] $CopyMetadata
    )

    process {
        $armObj = [ArmTemplate]$(Get-TaskWorkObject -Path $Path)

        $res = [ordered]@{}
        $res.'$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        $res.contentVersion = "1.0.0.0"
        $res.parameters = [ordered]@{}
      
        foreach ($item in $armObj.parameters.PsObject.Properties) {
            if ($item.Name -in $Exclude) { continue }
        
            if ($Include.Count -gt 0) {
                if (-not ($item.Name -in $Include)) { continue }
            }
        
            $valueObj = [ordered]@{}

            if ($BlankValues) {
                switch ($item.Value.Type) {
                    "int" {
                        $valueObj.value = 0
                    }
                    "bool" {
                        $valueObj.value = $false
                    }
                    "object" {
                        $valueObj.value = $null
                    }
                    "array" {
                        $valueObj.value = @()
                    }
                    Default {
                        $valueObj.value = ""
                    }
                }
            }
            else {
                $valueObj.value = $item.Value.DefaultValue
            }

            if ($CopyMetadata -and $item.Value.metadata) {
                $valueObj.metadata = $item.Value.metadata
            }

            $res.parameters."$($item.Name)" = $valueObj
        }

        if ($AsFile) {
            $pathLocal = $Path.Replace(".json", ".parameters.json")

            $encoding = New-Object System.Text.UTF8Encoding($true)
            [System.IO.File]::WriteAllLines($pathLocal, $($([PSCustomObject] $res) | ConvertTo-Json -Depth 10), $encoding)

            Get-Item -Path $pathLocal | Select-Object -ExpandProperty FullName
        }
        else {
            $([PSCustomObject] $res) | ConvertTo-Json -Depth 10
        }
    }
}