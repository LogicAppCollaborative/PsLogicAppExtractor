Task -Name "Initialize" -Description "" -Alias "Initialize.Initialize" -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
# ."$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes)\PsLogicAppExtractor.class.ps1"
    
    # Throw
    # Get-Module
    # $MyInvocation.MyCommand | ConvertTo-Json -Depth 2
    
    # Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base
    # Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks
    # Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes
}