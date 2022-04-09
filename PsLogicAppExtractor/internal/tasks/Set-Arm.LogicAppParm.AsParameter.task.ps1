$parm = @{
    Description = @"
Loops all internal / inner LogicApp parm (parameters)
-Creates an Arm parameter, with prefix & suffix
--Sets the default value (Arm parameter) to the original value from the parm
-Sets the default value (LogicApp parm) to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.LogicAppParm.AsParameter"
}

Task -Name "Set-Arm.LogicAppParm.AsParameter" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

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

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}