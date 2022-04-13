$parm = @{
    Description = @"
Loops all identity childs, which are UserAssigned
-Sets the value to an empty object
"@
    Alias       = "Raw.Set-Raw.UserAssignedIdentities.EmptyValue"
}

Task -Name "Set-Raw.UserAssignedIdentities.EmptyValue" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.identity | Where-Object type -eq UserAssigned | ForEach-Object {
        Foreach ($item in $_.userAssignedIdentities.PsObject.Properties) {
            $item.Value = @{}
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}