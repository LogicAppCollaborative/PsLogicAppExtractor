$parm = @{
    Description = @"
Creates an Arm parameter: logicAppLocation
-Set the default value to: [resourceGroup().location]
This is the current best practice, and will supress any validation errors in the different tools that exists
"@
    Alias       = "Arm.Set-Arm.Location.AsResourceGroup.AsParameter"
}

Task -Name "Set-Arm.Location.AsResourceGroup.AsParameter" @parm -Action {
    Set-TaskWorkDirectory
    
    $armObj = Get-TaskWorkObject

    $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppLocation" `
        -Type "string" `
        -Value "[resourceGroup().location]" `
        -Description "Location of the Logic App. Best practice recommendation is to make this depending on the Resource Group and its location."
    $armObj.resources[0].location = "[parameters('logicAppLocation')]"

    Out-TaskFileArm -InputObject $armObj
}