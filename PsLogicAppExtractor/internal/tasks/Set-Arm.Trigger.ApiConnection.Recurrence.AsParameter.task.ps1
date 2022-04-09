$parm = @{
    Description = @"
Creates an Arm parameter: trigger_Frequency
-Sets the default value to the original value, extracted from recurrence.frequency
-Sets the recurrence.frequency value to: [parameters('trigger_Frequency')]
Creates an Arm parameter: trigger_Interval
-Set the default value to the original value, extracted from recurrence.interval
-Sets the recurrence.interval value to: [parameters('trigger_Interval')]
Creates the evaluatedRecurrence property
-Sets the recurrence.frequency value to: [parameters('trigger_Frequency')]
-Sets the recurrence.interval value to: [parameters('trigger_Interval')]
"@
    Alias       = "Arm.Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter"
}

Task -Name "Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -eq "ApiConnection" -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence) {

        $frequencyPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Frequency"
        $intervalPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Interval"

        $orgFrequency = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.frequency
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$frequencyPreSuf" `
            -Type "string" `
            -Value $orgFrequency `
            -Description "The frequency used for the trigger to evalutate / run."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.frequency = "[parameters('$frequencyPreSuf')]"
        
        $orgInterval = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.interval
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$intervalPreSuf" `
            -Type "int" `
            -Value $orgInterval `
            -Description "The interval used for the trigger to evalutate / run."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.interval = "[parameters('$intervalPreSuf')]"

        if ($null -eq $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence) {
            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value | Add-Member -MemberType NoteProperty -Name "evaluatedRecurrence" -Value $([ordered]@{
                    frequency = "";
                    interval  = 1;
                })
        }

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.frequency = "[parameters('$frequencyPreSuf')]"
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.interval = "[parameters('$intervalPreSuf')]"
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}