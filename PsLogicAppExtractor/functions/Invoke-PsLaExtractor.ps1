<#
.SYNOPSIS
Execute the extractor process of the LogicApp

.DESCRIPTION
Execute all the tasks that have been defined in the build file, and get an ARM template as output

Depending on the initial extractor task that you are using, your powershell / az cli session needs to be signed in

Your build file can contain the tasks available from the module, but also your own custom tasks, that you want to have executed as part of the process

.PARAMETER BuildFile
Path to the PSake valid build file that you want to have executed while exporting, sanitizing and converting a LogicApp into a deployable ARM template

.PARAMETER SubscriptionId
Id of the subscription that you want to work against, your current powershell / az cli session either needs to "connected" to the subscription or at least have permissions to work against the subscription

.PARAMETER ResourceGroup
Name of the resource group that you want to work against, your current powershell / az cli session needs to have permissions to work against the resource group

.PARAMETER Name
Name of the logic app, that you want to work against

.PARAMETER WorkPath
Path to were the tasks will persist their outputs

Each task will save a file into a unique folder, containing the formatted output from its operation

You could risk that secrets or credentials are being stored on your disk, if they in some way are stored as clear text inside the logic app

The default valus is the current users TempPath, where it creates a "\PsLogicAppExtractor\GUID\" directory for each invoke

.EXAMPLE
PS C:\> Invoke-PsLaExtractor -BuildFile "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp

Invokes the different tasks inside the build file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake build file

.EXAMPLE
PS C:\> Invoke-PsLaExtractor -BuildFile "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"

Invokes the different tasks inside the build file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake build file

.EXAMPLE
PS C:\> Invoke-PsLaExtractor -BuildFile "C:\temp\LogicApp.ExportOnly.psakefile.ps1"

Invokes the different tasks inside the build file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake build file
The build file needs to have populated the Properties object, with the minimum: ResourceGroup and SubscriptionId

.EXAMPLE
PS C:\> Invoke-PsLaExtractor -BuildFile "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp -WorkPath "C:\temp\work_directory"

Invokes the different tasks inside the build file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake build file
Will output all tasks files into the "C:\temp\work_directory" location

.NOTES

Author: Mötz Jensen (@Splaxi)

#>
function Invoke-PsLaExtractor {
    [CmdletBinding(DefaultParameterSetName = "ResourceGroup")]
    param (
        [Alias('File')]
        [Parameter(Mandatory = $true, ParameterSetName = "PreppedFile")]
        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $BuildFile,

        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $ResourceGroup,

        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $Name,

        [string[]] $Task,

        [Alias('OutputPath')]
        [string] $WorkPath = "$([System.IO.Path]::GetTempPath())PsLogicAppExtractor\$([System.Guid]::NewGuid().Guid)"
    )

    #The task counter needs to be reset prior running
    $Script:TaskCounter = 0
    
    #Make sure the work path is created and available
    New-Item -Path $WorkPath -ItemType Directory -Force -ErrorAction Ignore > $null

    $parms = @{}
    $parms.buildFile = $BuildFile
    $parms.nologo = $true

    if ($Task) {
        $parms.taskList = $Task
    }
    
    $props = @{}
    if ($SubscriptionId) { $props.SubscriptionId = $SubscriptionId }
    if ($ResourceGroup) { $props.ResourceGroup = $ResourceGroup }
    if ($Name) { $props.Name = $Name }
    $props.PsLaWorkPath = $WorkPath

    $res = Invoke-psake @parms -properties $props -ErrorVariable errorsFound
    
    if ($errorsFound) {
        throw $res
    }

    Get-BuildOutput -Path $WorkPath
}