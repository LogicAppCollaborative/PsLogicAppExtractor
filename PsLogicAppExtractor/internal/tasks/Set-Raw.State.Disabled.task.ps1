$parm = @{
    Description = @"
Creates / assigns the state property in the LogicApp json structure
-Sets the value to: Disabled
"@
    Alias       = "Raw.Set-Raw.State.Disabled"
}

Task -Name "Set-Raw.State.Disabled" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    $lgObj.properties.state = "Disabled"
    
    Out-TaskFileLogicApp -InputObject $lgObj
}