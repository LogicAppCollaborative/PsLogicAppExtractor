$parm = @{
    Description = @"
Loops all identity childs, which are UserAssigned
-Sets the value to an empty object
"@
    Alias       = "Raw.Set-Raw.UserAssignedIdentities.EmptyValue"
}

Task -Name "Set-Raw.UserAssignedIdentities.EmptyValue" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath
    
    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath
    $lgObj.identity | Where-Object type -eq UserAssigned | ForEach-Object {
        Foreach ($item in $_.userAssignedIdentities.PsObject.Properties) {
            $item.Value = @{}
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}