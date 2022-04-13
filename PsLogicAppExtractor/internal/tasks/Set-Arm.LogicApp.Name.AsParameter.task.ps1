$parm = @{
    Description = @"
Creates an Arm parameter: logicAppName
-Sets the default value to the original name
"@
    Alias       = "Arm.Set-Arm.LogicApp.Name.AsParameter"
}

Task -Name "Set-Arm.LogicApp.Name.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject
    $orgName = $armObj.resources[0].name
    
    $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppName" `
        -Type "string" `
        -Value "$orgName" `
        -Description "Name of the Logic App. Makes it possible to override the name at deploy time."
    $armObj.resources[0].name = "[parameters('logicAppName')]"

    Out-TaskFileArm -InputObject $armObj
}