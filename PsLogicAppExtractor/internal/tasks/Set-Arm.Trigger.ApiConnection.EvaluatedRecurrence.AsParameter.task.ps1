$parm = @{
    Description = @"
    Creates an Arm parameter: trigger_EvalFrequency
    -Sets the default value to the original value, extracted from evaluatedRecurrence.frequency
    -Sets the evaluatedRecurrence.frequency value to: [parameters('trigger_EvalFrequency')]
    Creates an Arm parameter: trigger_EvalInterval
    -Set the default value to the original value, extracted from evaluatedRecurrence.interval
    -Sets the evaluatedRecurrence.interval value to: [parameters('trigger_EvalInterval')]
"@
    Alias       = "Arm.Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter"
}

Task -Name "Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -in @("ApiConnection", "Recurrence") -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence) {

        $frequencyPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalFrequency"
        $intervalPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalInterval"
        $startTimePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalStartTime"
        $timeZonePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalTimeZone"

        if ($null -eq @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.evaluatedRecurrence) {
            # Create the evaluatedRecurrence property if it does not exist
            @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value | Add-Member -MemberType NoteProperty -Name "evaluatedRecurrence" -Value $([ordered]@{
                    frequency = "Minute";
                    interval  = 1;
                })
        }

        # Handle the frequency property
        $orgFrequency = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.frequency
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$frequencyPreSuf" `
            -Type "string" `
            -Value $orgFrequency `
            -Description "The frequency used for the trigger to evaluate."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.frequency = "[parameters('$frequencyPreSuf')]"
        
        # Handle the interval property
        $orgInterval = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.interval
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$intervalPreSuf" `
            -Type "int" `
            -Value $orgInterval `
            -Description "The interval used for the trigger to evaluate."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.interval = "[parameters('$intervalPreSuf')]"

        # Handle the StartTime property
        $orgStartTime = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.startTime
        if (-not ($null -eq $orgStartTime)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$startTimePreSuf" `
                -Type "string" `
                -Value $orgStartTime `
                -Description "The start time used for the trigger to evaluate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.startTime = "[parameters('$startTimePreSuf')]"
        }

        # Handle the TimeZone property
        $orgTimeZone = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.timeZone
        if (-not ($null -eq $orgTimeZone)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$timeZonePreSuf" `
                -Type "string" `
                -Value $orgTimeZone `
                -Description "The time zone used for the trigger to evaluate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.timeZone = "[parameters('$timeZonePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}