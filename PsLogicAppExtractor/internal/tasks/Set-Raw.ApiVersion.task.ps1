$parm = @{
    Description = @"
Creates / assigns the ApiVersion property in the LogicApp json structure
-Sets the value to: `$ApiVersion (property passed as argument)
"@
    Alias       = "Raw.Set-Raw.ApiVersion"
}

Task -Name "Set-Raw.ApiVersion" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath
    $lgObj.apiVersion = $ApiVersion

    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}