$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type azureblob or azurefile
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the SubscriptionId, ResourceGroup, Namespace, Key
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the Api Connection Object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Storage.BlobOrFile.ListKey.Advanced.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Storage.BlobOrFile.ListKey.Advanced.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools

    $found = $false
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/azureblob*" -or $_.Value.id -like "*managedApis/azurefile*") {
            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)

            if ($tools -eq "AzCli") {
                $resObj = az rest --url $uri | ConvertFrom-Json
            }
            else {
                $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            }

            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName
            $resName = $resObj.Properties.ParameterValues.AccountName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Storage.BlobOrFile.AccessKey.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $subPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($_.Name)"
            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($_.Name)"
            $objPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_StorageAccount" -Value "$($_.Name)"
            
            $idPreSuf = Format-Name -Type "Connection" -Value "$($_.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($_.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$subPreSuf" `
                -Type "string" `
                -Value "[subscription().subscriptionId]" `
                -Description "The subscription where the storage account is located. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$rgPreSuf" `
                -Type "string" `
                -Value "[resourceGroup().name]" `
                -Description "The resource group where the storage account is located. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$objPreSuf" `
                -Type "string" `
                -Value "$resName" `
                -Description "The name of the storage account. ($($_.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$displayPreSuf" `
                -Type "string" `
                -Value $displayName `
                -Description "The display name of the ManagedApi connection object that is being utilized by the Logic App."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$displayPreSuf')]"
            $apiObj.properties.parameterValues.accountName = "[parameters('$objPreSuf')]"
            $apiObj.properties.parameterValues.accessKey = $apiObj.properties.parameterValues.accessKey.Replace("'##SUSCRIPTIONID##'", "parameters('$subPreSuf')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##ACCOUNTNAME##'", "parameters('$objPreSuf')")

            # Update the api connection object type
            $_.Value.id -match "/managedApis/(.*)"
            $conType = $Matches[1]
            $apiObj.properties.api.id = $apiObj.properties.api.id.Replace("##TYPE##", $conType)

            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }

            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $_.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $_.Value.connectionName = "[parameters('$idPreSuf')]"
            $_.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType', subscription().subscriptionId, parameters('logicAppLocation'))]"
        }
    }

    if ($found) {
        # We need the location parameter
        if ($null -eq $armObj.parameters.logicAppLocation) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppLocation" `
                -Type "string" `
                -Value "[resourceGroup().location]" `
                -Description "Location of the Logic App. Best practice recommendation is to make this depending on the Resource Group and its location."
        }
    }

    Out-TaskFileArm -InputObject $armObj
}