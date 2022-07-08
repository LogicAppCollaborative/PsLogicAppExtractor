
<#
    .SYNOPSIS
        Short description
        
    .DESCRIPTION
        Long description
        
    .PARAMETER Category
        Instruct the cmdlet which template type you want to have outputted
        
    .PARAMETER OutputPath
        Path to were the Task template file will be persisted
        
        The path has to be a directory
        
        The file will be named: _set-XYA.Template.ps1
        
    .EXAMPLE
        PS C:\> Get-PsLaTaskTemplate -Category "Arm"
        
        Outputs the task template of the type Arm to the console
        
    .EXAMPLE
        PS C:\> Get-PsLaTaskTemplate -Category "Arm" -OutputPath "C:\temp\work_directory"
        
        Outputs the task template of the type Arm
        Persists the file into the "C:\temp\work_directory" directory
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-PsLaTaskTemplate {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [ValidateSet('Arm', 'Converter', 'Raw')]
        [string] $Category,

        [PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
        [string] $OutputPath
    )

    if ($OutputPath) {
        Copy-Item -Path "$($script:ModuleRoot)\internal\tasks\_Set-$Category.Template.tmp" -Destination "$OutputPath\_Set-$Category.Template.ps1" -PassThru -Force | Select-Object -ExpandProperty FullName
    }
    else {
        Get-Content -Path "$($script:ModuleRoot)\internal\tasks\_Set-$Category.Template.tmp" -Raw
    }
}