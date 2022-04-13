$parm = @{
    Description = @"
Creates the evaluatedRecurrence property
-Sets the recurrence.frequency value to: [parameters('trigger_Frequency')]
-Sets the recurrence.interval value to: [parameters('trigger_Interval')]
"@
    Alias       = "Arm.Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter"
}

Task -Name "Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -eq "ApiConnection" -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence) {

        $frequencyPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Frequency"
        $intervalPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Interval"

        if ($null -eq @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.evaluatedRecurrence) {
            @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value | Add-Member -MemberType NoteProperty -Name "evaluatedRecurrence" -Value $([ordered]@{
                    frequency = "Minute";
                    interval  = 1;
                })
        }

        @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.evaluatedRecurrence.frequency = "[parameters('$frequencyPreSuf')]"
        @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.evaluatedRecurrence.interval = "[parameters('$intervalPreSuf')]"
    }

    Out-TaskFileArm -InputObject $armObj
}