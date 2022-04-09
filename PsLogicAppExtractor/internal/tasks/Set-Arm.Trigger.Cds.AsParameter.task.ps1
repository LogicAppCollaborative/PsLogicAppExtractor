$parm = @{
    Description = @"
Creates an Arm parameter: apostrophe - with prefix & suffix
-Sets the default value to: '
--Used for making the concat function work properly
Creates an Arm parameter: Uri - with prefix & suffix
-Sets the default value to the original value, extracted from inputs.path
Sets the inputs.path value to: [concat('/v2/datasets/...., parameters('apostrophe'), parameters('Uri'), parameters('apostrophe'), /triggers/...')]
"@
    Alias       = "Arm.Set-Arm.Trigger.Cds.AsParameter"
}

Task -Name "Set-Arm.Trigger.Cds.AsParameter" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -eq "ApiConnectionWebhook" -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.path -like "*/tables/*" -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.host -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.queries.scope) {

        if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.path -Match "/.*(https://.*\.com)") {
            $uriValue = $Matches[1]
        
            $apostrophePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "apostrophe"
            $uriPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Uri"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$apostrophePreSuf" `
                -Type "string" `
                -Value "'" `
                -Description "Used for the trigger concat function, to make things work when deploying the template."
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$uriPreSuf" `
                -Type "string" `
                -Value $uriValue `
                -Description "The uri for the Cds instance that the trigger should be configured to run against."
    
            $oldPath = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.path
            $parts = $oldPath.Replace($uriValue, "|").Split("|")

            $parts[1] = $parts[1].Replace("'", "''").Replace("''))}/tables", "'))}/tables")
            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.path = "[concat('$($parts[0]), parameters('$apostrophePreSuf'), parameters('$uriPreSuf'), parameters('$apostrophePreSuf'), $($parts[1])')]"
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}