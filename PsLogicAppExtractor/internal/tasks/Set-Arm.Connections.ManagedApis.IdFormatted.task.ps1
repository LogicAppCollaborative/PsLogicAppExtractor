﻿$parm = @{
    Description = @"
Loops all `$connections children
-Sets the id value to: [format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/XYZ', subscription().subscriptionId, parameters('logicAppLocation'))]
Creates the Arm parameter logicAppLocation if it doesn't exists
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.IdFormatted"
}

Task -Name "Set-Arm.Connections.ManagedApis.IdFormatted" @parm -Action {
    Set-TaskWorkDirectory
    
    $found = $false

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis*" `
                -and (-not ($connectionObj.Value.id -like "*[*(*)*]*")) `
        ) {
            $found = $true

            $conType = $connectionObj.Value.id.Split("/") | Select-Object -Last 1
            $connectionObj.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType', subscription().subscriptionId, parameters('logicAppLocation'))]"
        }
    }

    if ($found) {
        if ($null -eq $armObj.parameters.logicAppLocation) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppLocation" `
                -Type "string" `
                -Value "[resourceGroup().location]" `
                -Description "Location of the Logic App. Best practice recommendation is to make this depending on the Resource Group and its location."
        }
    }

    Out-TaskFileArm -InputObject $armObj
}