$parm = @{
    Description = @"
Creates an Arm parameter: integrationAccount
-Set the default value to the original name, extracted from integrationAccount.Id
Sets the value of the integrationAccount.Id: [format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}',subscription().subscriptionId,resourceGroup().name,parameters('integrationAccount'))]
"@
    Alias       = "Arm.Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter"
}

Task -Name "Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.integrationAccount.id) {
        $integrationAccountName = $armObj.resources[0].properties.integrationAccount.id.Split("/") | Select-Object -Last 1
        $armObj.resources[0].properties.integrationAccount.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}',subscription().subscriptionId,resourceGroup().name,parameters('integrationAccount'))]"

        $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("name")
        $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("type")

        $armObj = Add-ArmParameter -InputObject $armObj -Name "integrationAccount" `
            -Type "string" `
            -Value "$integrationAccountName" `
            -Description "The name / id of the Integration Account that is being utilized by the Logic App."
    }

    Out-TaskFileArm -InputObject $armObj
}