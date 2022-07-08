
<#
    .SYNOPSIS
        Short description
        
    .DESCRIPTION
        Long description
        
    .PARAMETER Source
        Parameter description
        
    .PARAMETER Destination
        Parameter description
        
    .PARAMETER SkipParameters
        Parameter description
        
    .PARAMETER SkipResources
        Parameter description
        
    .PARAMETER RemoveSource
        Parameter description
        
    .EXAMPLE
        An example
        
    .NOTES
        General notes
#>
function Update-PsLaArmTemplate {
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

    if($RemoveSource) {
        Remove-Item -Path $Source -Force -Recurse -ErrorAction SilentlyContinue
    }
}