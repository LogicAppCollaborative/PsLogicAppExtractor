$parm = @{
    Description = @"
Creates / assigns the state property in the LogicApp json structure
-Sets the value to: Disabled
"@
    Alias       = "Raw.Set-Raw.State.Disabled"
}

Task -Name "Set-Raw.State.Disabled" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath
    $lgObj.properties.state = "Disabled"
    
    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}