$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.Trigger.Dataverse.CallBack.AsParameter"
}

Task -Name "Set-Arm.Trigger.Dataverse.CallBack.AsParameter" @parm -Action {
    Set-TaskWorkDirectory
     
    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -eq "ApiConnectionWebhook" -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.path -like "*/callbackregistrations" -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.headers.organization -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.entityname) {

        if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.headers.organization -like "https://*.dynamics.com" -and
            -not ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.headers.organization -like "*[*]*")) {
            $uriValue = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.headers.organization
        
            $uriPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Uri"
           
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$uriPreSuf" `
                -Type "string" `
                -Value $uriValue `
                -Description "The uri for the Dataverse instance that the trigger should be configured to run against."
    
            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.headers.organization = "[parameters('$uriPreSuf')]"
        }

        if (-not ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.entityname -like "*[*]*")) {
            $entityValue = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.entityname

            $entityPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Entity"
           
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$entityPreSuf" `
                -Type "string" `
                -Value $entityValue `
                -Description "The entity in Dataverse that the trigger should be configured to run against."
    
            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.entityname = "[parameters('$entityPreSuf')]"
        }

        if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.filteringattributes -and
            -not ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.filteringattributes -like "*[*]*")) {
            $attValue = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.filteringattributes

            $attPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Attributes"
           
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$attPreSuf" `
                -Type "string" `
                -Value $attValue `
                -Description "The attributes/columns/properties on the entity in Dataverse that the trigger should be configured to run against."
    
            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.inputs.body.filteringattributes = "[parameters('$attPreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}