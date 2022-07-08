
<#
    .SYNOPSIS
        Update ARM template from another ARM template.
        
    .DESCRIPTION
        Update an ARM template, with the content of another ARM template.

        You can update the entire ARM template, or just a part of it.

        Supports the following options:
        * Full
        * SkipResources
        * SkipParameters
        
    .PARAMETER Source
        The path for the source ARM template to be used as the changes you want to apply.
        
    .PARAMETER Destination
        The path for the destination ARM template to be updated.
        
    .PARAMETER SkipParameters
        If true, then the parameters will not be updated.
        
    .PARAMETER SkipResources
        If true, then the resources will not be updated.
        
    .PARAMETER RemoveSource
        If true, then the source ARM template will be removed after it has been used.
        
    .EXAMPLE
        PS C:\> Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json

        This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
        It will overwrite the entire ARM template, but will not remove the source ARM template.
        
    .EXAMPLE
        PS C:\> Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json -SkipParameters

        This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
        It will overwrite the entire ARM template, but leave the parameters alone.

    .EXAMPLE
        PS C:\> Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json -SkipResources

        This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
        It will overwrite the entire ARM template, but leave the resources alone.

    .EXAMPLE
        PS C:\> Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json -RemoveSource

        This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
        It will overwrite the entire ARM template, and remove the source ARM template.

    .NOTES
        Author: Mötz Jensen (@Splaxi)
#>
function Update-PsLaArmTemplate {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [string] $Source,

        [parameter(Mandatory = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [string] $Destination,

        [switch] $SkipParameters,

        [switch] $SkipResources,

        [switch] $RemoveSource
    )

    process {
        #The task counter needs to be reset prior running
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0

        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value ""
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskOutputFile -Value ""
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskPath -Value ""
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.Name -Value ""
        
        $armObjSource = Get-TaskWorkObject -Path $Source
        $armObjDestination = Get-TaskWorkObject -Path $Destination

        if (-not $SkipParameters) {
            # "Before ####"
            # $armObjDestination.parameters | ConvertTo-Json -Depth 10
            # "Before ####"
            $armObjDestination.parameters = $armObjSource.parameters | ConvertTo-Json -Depth 10 | ConvertFrom-Json -Depth 10
            # "After ####"
            # $armObjDestination.parameters | ConvertTo-Json -Depth 10
            # "After ####"
        }

        if (-not $SkipResources) {
            $armObjDestination.resources = @($armObjSource.resources | ConvertTo-Json -Depth 100 | ConvertFrom-Json -Depth 100)
        }

        Out-TaskFile -Path $Destination -InputObject $([ArmTemplate]$armObjDestination)

        if ($RemoveSource) {
            Remove-Item -Path $Source -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
}