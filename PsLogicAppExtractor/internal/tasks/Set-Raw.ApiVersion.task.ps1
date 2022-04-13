$parm = @{
    Description = @"
Creates / assigns the ApiVersion property in the LogicApp json structure
-Sets the value to: `$ApiVersion (property passed as argument)
"@
    Alias       = "Raw.Set-Raw.ApiVersion"
}

Task -Name "Set-Raw.ApiVersion" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    $lgObj.apiVersion = $ApiVersion

    Out-TaskFileLogicApp -InputObject $lgObj
}