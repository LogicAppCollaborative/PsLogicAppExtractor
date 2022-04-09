function Get-BuildOutput {
    [CmdletBinding()]
    param (

        [Alias('WorkPath')]
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    
    $files = Get-ChildItem -Path $Path -Recurse -File
    $files | Sort-Object -Property LastWriteTime | Select-Object -Last 1 -ExpandProperty FullName
}