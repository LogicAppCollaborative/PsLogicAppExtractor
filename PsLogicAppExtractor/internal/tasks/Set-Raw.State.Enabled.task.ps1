$parm = @{
    Description = @"
Creates / assigns the state property in the LogicApp json structure
-Sets the value to: Enabled
"@
    Alias       = "Raw.Set-Raw.State.Enabled"
}

Task -Name "Set-Raw.State.Enabled" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    $lgObj.properties.state = "Enabled"
    
    Out-TaskFileLogicApp -InputObject $lgObj
}