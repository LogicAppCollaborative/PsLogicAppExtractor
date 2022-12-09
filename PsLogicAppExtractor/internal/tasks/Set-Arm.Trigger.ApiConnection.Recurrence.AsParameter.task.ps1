$parm = @{
    Description = @"
Creates an Arm parameter: trigger_Frequency
-Sets the default value to the original value, extracted from recurrence.frequency
-Sets the recurrence.frequency value to: [parameters('trigger_Frequency')]
Creates an Arm parameter: trigger_Interval
-Set the default value to the original value, extracted from recurrence.interval
-Sets the recurrence.interval value to: [parameters('trigger_Interval')]
"@
    Alias       = "Arm.Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter"
}

Task -Name "Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -in @("ApiConnection", "Recurrence") -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence) {

        $frequencyPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Frequency"
        $intervalPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Interval"
        $startTimePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "StartTime"
        $timeZonePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "TimeZone"

        # Handle the Frequency property
        $orgFrequency = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.frequency
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$frequencyPreSuf" `
            -Type "string" `
            -Value $orgFrequency `
            -Description "The frequency used for the trigger to run."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.frequency = "[parameters('$frequencyPreSuf')]"
        
        # Handle the Interval property
        $orgInterval = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.interval
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$intervalPreSuf" `
            -Type "int" `
            -Value $orgInterval `
            -Description "The interval used for the trigger to run."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.interval = "[parameters('$intervalPreSuf')]"

        # Handle the StartTime property
        $orgStartTime = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.startTime
        if (-not ($null -eq $orgStartTime)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$startTimePreSuf" `
                -Type "string" `
                -Value $orgStartTime `
                -Description "The start time used for the trigger to evalutate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.startTime = "[parameters('$startTimePreSuf')]"
        }

        # Handle the TimeZone property
        $orgTimeZone = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.timeZone
        if (-not ($null -eq $orgTimeZone)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$timeZonePreSuf" `
                -Type "string" `
                -Value $orgTimeZone `
                -Description "The time zone used for the trigger to evalutate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.timeZone = "[parameters('$timeZonePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}