$parm = @{
    Description = @"
Loops all internal / inner LogicApp parm (parameters)
-Creates an Arm variable, with prefix & suffix
--Sets the value (Arm variable) to the original value from the parm
-Sets the default value (LogicApp parm) to: [variables('XYZ')]
"@
    Alias       = "Arm.Set-Arm.LogicAppParm.AsVariable"
}

Task -Name "Set-Arm.LogicAppParm.AsVariable" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    $armObj.resources[0].properties.definition.parameters.PsObject.Properties | ForEach-Object {
        if ($_.Name -ne '$connections') {
            $namePreSuf = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value $_.Name

            $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $($_.Value.defaultValue)
            $_.Value.defaultValue = "[variables('$namePreSuf')]"
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}