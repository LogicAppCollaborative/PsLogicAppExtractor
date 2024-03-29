﻿$parm = @{
    Description = @"
Loops all `$connections children
-Creates an Arm parameter, with prefix & suffix
--Sets the default value to the original name, extracted from connectionName property
-Sets the connectionId to: [resourceId('Microsoft.Web/connections', parameters('XYZ'))]
-Sets the connectionName to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Name.AsParameter"
}

Task -Name "Set-Arm.Connections.ManagedApis.Name.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis*" `
                -and (-not ($connectionObj.Value.connectionName -like "*[*(*)*]*")) `
                -and (-not ($connectionObj.Value.id -like "*[*(*)*]*")) `
        ) {
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $conName = $connectionObj.Value.connectionName
            $namePreSuf = Format-Name -Type "Connection" -Value $connectionObj.Name

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
    
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$namePreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}