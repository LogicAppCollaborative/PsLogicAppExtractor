$parm = @{
    Description = @"
Converts the raw LogicApp json structure into the a valid LogicApp json,
this will remove different properties that are not needed
"@
    Alias       = "Converter.ConvertTo-LogicApp.Basic"
}

Task -Name "ConvertTo-LogicApp.Basic" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }

    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath
    
    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath

    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}