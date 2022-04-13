$parm = @{
    Description = @"
Loops all internal / inner LogicApp parm (parameters)
-Creates an Arm variable, with prefix & suffix
--Sets the value (Arm variable) to the original value from the parm
-Sets the default value (LogicApp parm) to: [variables('XYZ')]
"@
    Alias       = "Arm.Set-Arm.LogicApp.Parm.AsVariable"
}

Task -Name "Set-Arm.LogicApp.Parm.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.definition.parameters.PsObject.Properties | ForEach-Object {
        if ($_.Name -ne '$connections') {
            $namePreSuf = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value $_.Name

            $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $($_.Value.defaultValue)
            $_.Value.defaultValue = "[variables('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}