$parm = @{
    Description = @"
Creates / assigns the state property in the LogicApp json structure
-Sets the value to: Enabled
"@
    Alias       = "Raw.Set-Raw.State.Enabled"
}

Task -Name "Set-Raw.State.Enabled" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath
    $lgObj.properties.state = "Enabled"
    
    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}