$parm = @{
    Description = @"
Creates an Arm variable: integrationAccount
-Set the value to the original name, extracted from integrationAccount.Id
Sets the value of the integrationAccount.Id: [format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId, resourceGroup().name,variables('integrationAccount'))]
"@
    Alias       = "Arm.Set-Arm.IntegrationAccount.IdFormatted.Simple.AsVariable"
}

Task -Name "Set-Arm.IntegrationAccount.IdFormatted.Simple.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.integrationAccount.id) {
        $integrationAccountName = $armObj.resources[0].properties.integrationAccount.id.Split("/") | Select-Object -Last 1
        $armObj.resources[0].properties.integrationAccount.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId, resourceGroup().name,variables('integrationAccount'))]"

        $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("name")
        $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("type")

        $armObj = Add-ArmVariable -InputObject $armObj -Name "integrationAccount" -Value "$integrationAccountName"
    }

    Out-TaskFileArm -InputObject $armObj
}