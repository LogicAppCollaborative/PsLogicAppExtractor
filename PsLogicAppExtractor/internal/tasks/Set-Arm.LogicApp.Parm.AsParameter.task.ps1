$parm = @{
    Description = @"
Loops all internal / inner LogicApp parm (parameters)
-Creates an Arm parameter, with prefix & suffix
--Sets the default value (Arm parameter) to the original value from the parm
-Sets the default value (LogicApp parm) to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.LogicApp.Parm.AsParameter"
}

Task -Name "Set-Arm.LogicApp.Parm.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.definition.parameters.PsObject.Properties | ForEach-Object {
        if ($_.Name -ne '$connections') {
            $namePreSuf = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value $_.Name

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
                -Type "$($_.Value.type)" `
                -Value $($_.Value.defaultValue) `
                -Description "A parameter that is defined inside in the Logic App. Not to be confused with parameters for the Arm Template deployment."
            $_.Value.defaultValue = "[parameters('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}