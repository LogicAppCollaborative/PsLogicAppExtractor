$parm = @{
    Description = @"
Creates an Arm variable: integrationAccount
-Set the value to the original name, extracted from integrationAccount.Id
Creates an Arm variable: integrationAccountResourceGroup
-Set the value to the original resource group, extracted from integrationAccount.Id
Sets the value of the integrationAccount.Id: [format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}',subscription().subscriptionId,variables('integrationAccountResourceGroup'),variables('integrationAccount'))]
"@
    Alias       = "Arm.Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsVariable"
}

Task -Name "Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsVariable" @parm -Action {
    Set-TaskWorkDirectory
    
    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.integrationAccount.id) {
        if ($armObj.resources[0].properties.integrationAccount.id -match "resourceGroups/(.*)/providers") {

            $integrationAccountName = $armObj.resources[0].properties.integrationAccount.id.Split("/") | Select-Object -Last 1

            $armObj.resources[0].properties.integrationAccount.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}',subscription().subscriptionId,variables('integrationAccountResourceGroup'),variables('integrationAccount'))]"

            $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("name")
            $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("type")

            $armObj = Add-ArmVariable -InputObject $armObj -Name "integrationAccount" -Value "$integrationAccountName"
            $armObj = Add-ArmVariable -InputObject $armObj -Name "integrationAccountResourceGroup" -Value "$($Matches[1])"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}