
<#
    .SYNOPSIS
        Get the output file
        
    .DESCRIPTION
        Get the full path of the "latest" file from the workpath of the runbook / extraction process
        
        Notes: It is considered as an internal function, and should not be used directly.
        
    .PARAMETER Path
        Path to the workpath where the runbook has been persisting files
        
    .EXAMPLE
        PS C:\> Get-ExtractOutput -Path "C:\temp\work_directory"
        
        Returns the full path of the latest written file from the "C:\temp\work_directory" path
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
        This is considered as an internal function, and should not be used directly.
#>
function Get-ExtractOutput {
    [CmdletBinding()]
    param (

        [Alias('WorkPath')]
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    
    $files = Get-ChildItem -Path $Path -Recurse -File
    $files | Sort-Object -Property LastWriteTime | Select-Object -Last 1 -ExpandProperty FullName
}