$parm = @{
    Description = @"
Creates an Arm parameter: logicAppState
-Sets the default value to the original state of the Logic App
"@
    Alias       = "Arm.Set-Arm.LogicApp.State.AsParameter"
}

Task -Name "Set-Arm.LogicApp.State.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject
    $orgValue = $armObj.resources[0].properties.state
    
    $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppState" `
        -Type "string" `
        -Value "$orgValue" `
        -Description "State of the Logic App when is being deployed. Makes it possible to override the name at deploy time."
    $armObj.resources[0].properties.state = "[parameters('logicAppState')]"

    Out-TaskFileArm -InputObject $armObj
}