$parm = @{
    Description = @"
Creates an Arm parameter: integrationAccount
-Set the default value to the original name, extracted from integrationAccount.Id
Creates an Arm parameter: integrationAccountResourceGroup
-Set the default value to the original resource group, extracted from integrationAccount.Id
Sets the value of the integrationAccount.Id: [format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}',subscription().subscriptionId,parameters('integrationAccountResourceGroup'),parameters('integrationAccount'))]
"@
    Alias       = "Arm.Set-Arm.IntegrationAccount.IdFormatted.Advanced"
}

Task -Name "Set-Arm.IntegrationAccount.IdFormatted.Advanced" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    if ($armObj.resources[0].properties.integrationAccount.id) {
        if ($armObj.resources[0].properties.integrationAccount.id -match "resourceGroups/(.*)/providers") {
            $integrationAccountName = $armObj.resources[0].properties.integrationAccount.id.Split("/") | Select-Object -Last 1
            $armObj.resources[0].properties.integrationAccount.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}',subscription().subscriptionId,parameters('integrationAccountResourceGroup'),parameters('integrationAccount'))]"

            $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("name")
            $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("type")

            $armObj = Add-ArmParameter -InputObject $armObj -Name "integrationAccount" `
                -Type "string" `
                -Value "$integrationAccountName" `
                -Description "The name / id of the Integration Account that is being utilized by the Logic App."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "integrationAccountResourceGroup" `
                -Type "string" `
                -Value $Matches[1] `
                -Description "The resource group where the Integration Account that is being utilized by the Logic App is located."

        }
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}