﻿
#Original file: ConvertTo-Arm.task.ps1
$parm = @{
    Description = "Converts the LogicApp json structure into a valid ARM template json"
    Alias       = "Converter.ConvertTo-Arm"
}

Task -Name "ConvertTo-Arm" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject

    $armObj = [ArmTemplate][PSCustomObject]@{
        '$schema'      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{}
        variables      = @{}
        outputs        = @{}
    }

    $armObj.resources = @($lgObj)
    
    Out-TaskFileArm -InputObject $armObj
}


#Original file: ConvertTo-Raw.task.ps1
$parm = @{
    Description = @"
Converts the exported LogicApp json structure into the a valid LogicApp json,
this will remove different properties that are not needed
"@
    Alias       = "Converter.ConvertTo-Raw"
}

Task -Name "ConvertTo-Raw" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Export-LogicApp.AzAccount.task.ps1
$parm = @{
    Description = "Exports the raw version of the Logic App from the Azure Portal"
    Alias       = "Exporter.Export-LogicApp.AzAccount"
}

Task -Name "Export-LogicApp.AzAccount" @parm -Action {
    Set-TaskWorkDirectory
    
    $params = @{
        ResourceGroupName    = "$ResourceGroup"
        ResourceProviderName = 'Microsoft.Logic'
        ResourceType         = 'workflows'
        Name                 = "$Name"
        ApiVersion           = "2019-05-01"
        Method               = 'GET'
    }

    if ($SubscriptionId) {
        $params.SubscriptionId = "$SubscriptionId"
    }

    $lg = Invoke-AzRestMethod @params
    
    if ($null -eq $lg) {
        #TODO! We need to throw an error
        Throw
    }
    
    $res = $lg.Content
    Out-TaskFile -Content $res
}

#Original file: Export-LogicApp.AzCli.task.ps1
$parm = @{
    Description = "Exports the raw version of the Logic App from the Azure Portal"
    Alias       = "Exporter.Export-LogicApp.AzCli"
}

Task -Name "Export-LogicApp.AzCli" @parm -Action {
    Set-TaskWorkDirectory
    
    if ($SubscriptionId -and $ResourceGroup) {
        $lg = az rest --url "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Logic/workflows/$Name" --url-parameters api-version=2019-05-01
    }
    else {
        $id = az resource show --resource-group $ResourceGroup --resource-type "Microsoft.Logic/workflows" --Name $Name --query "id" | ConvertFrom-Json
        $lg = az rest --url "$id" --url-parameters api-version=2019-05-01
    }
    
    if ($null -eq $lg) {
        #TODO! We need to throw an error
        Throw
    }
    
    $res = $lg -join ""
    Out-TaskFile -Content $res
}

#Original file: Export-Raw.Connections.ManagedApis.DisplayName.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Exports the DisplayName of the ManagedApis based on the ConnectionId / ResourceId
--Sets connectionName to the DisplayName, extracted via the ConnectionId
Requires an authenticated Az.Accounts session
"@
    Alias       = "Exporter.Export-Raw.Connections.ManagedApis.DisplayName.AzAccount"
}

Task -Name "Export-Raw.Connections.ManagedApis.DisplayName.AzAccount" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {

            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)

            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json

            $conName = $resObj.Properties.DisplayName
            $_.Value.connectionName = $conName
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Export-Raw.Connections.ManagedApis.DisplayName.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Exports the DisplayName of the ManagedApis based on the ConnectionId / ResourceId
--Sets connectionName to the DisplayName, extracted via the ConnectionId
Requires an authenticated Az.Accounts session
"@
    Alias       = "Exporter.Export-Raw.Connections.ManagedApis.DisplayName.AzCli"
}

Task -Name "Export-Raw.Connections.ManagedApis.DisplayName.AzCli" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {

            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)

            $resObj = az rest --url $uri | ConvertFrom-Json

            $conName = $resObj.Properties.DisplayName
            $_.Value.connectionName = $conName
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Arm.Connections.ManagedApis.AsParameter.task.ps1
$parm = @{
    Description = @"
Depricated. Use Set-Arm.Connections.ManagedApis.Id.AsParameter.task instead.

Loops all `$connections children
-Creates an Arm parameter, with prefix & suffix
--Sets the default value to the original name, extracted from connectionId property
-Sets the connectionId to: [resourceId('Microsoft.Web/connections', parameters('XYZ'))]
-Sets the connectionName to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AsParameter"
}

Task -Name "Set-Arm.Connections.ManagedApis.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $namePreSuf = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value $_.Name
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
    
            $_.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$namePreSuf'))]"
            $_.Value.connectionName = "[parameters('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Connections.ManagedApis.AsVariable.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Creates an Arm variable, with prefix & suffix
--Sets the value to the original name, extracted from connectionId property
-Sets the connectionId to: [resourceId('Microsoft.Web/connections', variables('XYZ'))]
-Sets the connectionName to: [variables('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AsVariable"
}

Task -Name "Set-Arm.Connections.ManagedApis.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $namePreSuf = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value $_.Name
            
            $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $conName
    
            $_.Value.connectionId = "[resourceId('Microsoft.Web/connections', variables('$namePreSuf'))]"
            $_.Value.connectionName = "[variables('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.Advanced.AsArmObject.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type azureblob
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the SubscriptionId, ResourceGroup, Namespace, Key
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the Api Connection Object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.Advanced.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.Advanced.AsArmObject.AzAccount" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "azureblob"
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/azureblob*") {
            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json

            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName
            $resName = $resObj.Properties.ParameterValues.AccountName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.AzureBlob.AccessKey.json" -Raw | ConvertFrom-Json

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

#Original file: Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.Advanced.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type azureblob
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the SubscriptionId, ResourceGroup, Namespace, Key
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the Api Connection Object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.Advanced.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.Advanced.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "azureblob"
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/azureblob*") {
            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json

            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName
            $resName = $resObj.Properties.ParameterValues.AccountName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.AzureBlob.AccessKey.json" -Raw | ConvertFrom-Json

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

#Original file: Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.AsArmObject.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type azureblob
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the SubscriptionId, ResourceGroup, Namespace, Key
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the ConnectionName property
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.AsArmObject.AzAccount" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "azureblob"
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/azureblob*") {
            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json

            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName
            $resName = $resObj.Properties.ParameterValues.AccountName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.AzureBlob.AccessKey.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $subPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($_.Name)"
            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($_.Name)"
            $objPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_StorageAccount" -Value "$($_.Name)"
            $idPreSuf = Format-Name -Type "Connection" -Value "$($_.Name)"
            
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

            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            $apiObj.properties.parameterValues.accountName = "[parameters('$objPreSuf')]"
            $apiObj.properties.parameterValues.accessKey = $apiObj.properties.parameterValues.accessKey.Replace("'##SUSCRIPTIONID##'", "parameters('$subPreSuf')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##ACCOUNTNAME##'", "parameters('$objPreSuf')")

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

#Original file: Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type azureblob
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the SubscriptionId, ResourceGroup, Namespace, Key
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the ConnectionName property
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.AzureBlob.ListKey.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "azureblob"
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/azureblob*") {
            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json

            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName
            $resName = $resObj.Properties.ParameterValues.AccountName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.AzureBlob.AccessKey.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $subPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($_.Name)"
            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($_.Name)"
            $objPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_StorageAccount" -Value "$($_.Name)"
            $idPreSuf = Format-Name -Type "Connection" -Value "$($_.Name)"
            
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

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            $apiObj.properties.parameterValues.accountName = "[parameters('$objPreSuf')]"
            $apiObj.properties.parameterValues.accessKey = $apiObj.properties.parameterValues.accessKey.Replace("'##SUSCRIPTIONID##'", "parameters('$subPreSuf')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##ACCOUNTNAME##'", "parameters('$objPreSuf')")

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

#Original file: Set-Arm.Connections.ManagedApis.Generic.Advanced.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type ManagedApi
--Creates a new resource in the ARM template, for the ApiConnection object
--Makes sure the ARM Parameters logicAppLocation exists
--Name & Displayname is extracted from the Api Connection Object
--Extends the dependsOn property on the LogicApp resource, to depend on the ApiConnection object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Generic.Advanced.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.Generic.Advanced.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -match "/managedApis/(.*)") {
            
            # We have specialized templates for these types
            if ($Matches[1] -in @("azureblob", "azurefile", "servicebus")) { continue }

            $found = $true
            $conType = $Matches[1]

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName
            
            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Managed.json" -Raw | ConvertFrom-Json

            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($connectionObj.Name)"

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
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
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

#Original file: Set-Arm.Connections.ManagedApis.Generic.AsArmObject.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type ManagedApi
--Creates a new resource in the ARM template, for the ApiConnection object
--Makes sure the ARM Parameters logicAppLocation exists
--Name & Displayname is extracted from the ConnectionName property
--Extends the dependsOn property on the LogicApp resource, to depend on the ApiConnection object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Generic.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Connections.ManagedApis.Generic.AsArmObject.AzAccount" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -match "/managedApis/(.*)") {
            
            # We have specialized templates for these types
            if ($Matches[1] -in @("azureblob", "azurefile", "servicebus")) { continue }

            $found = $true
            $conType = $Matches[1]

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName
            
            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
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
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
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

#Original file: Set-Arm.Connections.ManagedApis.Generic.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type ManagedApi
--Creates a new resource in the ARM template, for the ApiConnection object
--Makes sure the ARM Parameters logicAppLocation exists
--Name & Displayname is extracted from the ConnectionName property
--Extends the dependsOn property on the LogicApp resource, to depend on the ApiConnection object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Generic.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.Generic.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -match "/managedApis/(.*)") {
            
            # We have specialized templates for these types
            if ($Matches[1] -in @("azureblob", "servicebus")) { continue }

            $found = $true
            $conType = $Matches[1]

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName
            
            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
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
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
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

#Original file: Set-Arm.Connections.ManagedApis.Id.AsParameter.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Creates an Arm parameter, with prefix & suffix
--Sets the default value to the original name, extracted from connectionId property
-Sets the connectionId to: [resourceId('Microsoft.Web/connections', parameters('XYZ'))]
-Sets the connectionName to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Id.AsParameter"
}

Task -Name "Set-Arm.Connections.ManagedApis.Id.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $namePreSuf = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value $_.Name
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
    
            $_.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$namePreSuf'))]"
            $_.Value.connectionName = "[parameters('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Connections.ManagedApis.IdFormatted.task.ps1
$parm = @{
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

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $found = $true
            $conType = $_.Value.id.Split("/") | Select-Object -Last 1
            $_.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType', subscription().subscriptionId, parameters('logicAppLocation'))]"
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

#Original file: Set-Arm.Connections.ManagedApis.Name.AsParameter.task.ps1
$parm = @{
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

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionName
            $namePreSuf = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value $_.Name
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
    
            $_.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$namePreSuf'))]"
            $_.Value.connectionName = "[parameters('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ListKey.Advanced.AsArmObject.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus, and that is using the classic connection string approach
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the ResourceGroup, Namespace, AccessKey
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the Api Connection Object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ListKey.Advanced.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ListKey.Advanced.AsArmObject.AzAccount" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {
        
            # This should only handle the classic Servicebus connections based on ListKey
            if ($connectionObj.Value.connectionProperties.authentication.type -eq "ManagedServiceIdentity") { continue }
        
            $found = $true
        
            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.ConnectionString.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $subPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($connectionObj.Name)"
            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($connectionObj.Name)"
            $objPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"
            $keyPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Key" -Value "$($connectionObj.Name)"

            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($connectionObj.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$subPreSuf" `
                -Type "string" `
                -Value "[subscription().subscriptionId]" `
                -Description "The subscription where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$rgPreSuf" `
                -Type "string" `
                -Value "[resourceGroup().name]" `
                -Description "The resource group where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$objPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$displayPreSuf" `
                -Type "string" `
                -Value $displayName `
                -Description "The display name of the ManagedApi connection object that is being utilized by the Logic App."
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$keyPreSuf" `
                -Type "string" `
                -Value "RootManageSharedAccessKey" `
                -Description "The name of the namespace access policy key that will be used during the deployment to fetch the connection string based on that key. ($($connectionObj.Name))"
            
            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$displayPreSuf')]"
            $apiObj.properties.parameterValues.connectionString = $apiObj.properties.parameterValues.connectionString.Replace("'##SUSCRIPTIONID##'", "parameters('$subPreSuf')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##NAMESPACE##'", "parameters('$objPreSuf')").Replace("'##KEYNAME##'", "parameters('$keyPreSuf')")
            
            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }

            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
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

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ListKey.Advanced.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus, and that is using the classic connection string approach
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the ResourceGroup, Namespace, AccessKey
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the Api Connection Object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ListKey.Advanced.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ListKey.Advanced.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {
        
            # This should only handle the classic Servicebus connections based on ListKey
            if ($connectionObj.Value.connectionProperties.authentication.type -eq "ManagedServiceIdentity") { continue }
        
            $found = $true
        
            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.ConnectionString.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $subPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($connectionObj.Name)"
            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($connectionObj.Name)"
            $objPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"
            $keyPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Key" -Value "$($connectionObj.Name)"

            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($connectionObj.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$subPreSuf" `
                -Type "string" `
                -Value "[subscription().subscriptionId]" `
                -Description "The subscription where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$rgPreSuf" `
                -Type "string" `
                -Value "[resourceGroup().name]" `
                -Description "The resource group where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$objPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$displayPreSuf" `
                -Type "string" `
                -Value $displayName `
                -Description "The display name of the ManagedApi connection object that is being utilized by the Logic App."
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$keyPreSuf" `
                -Type "string" `
                -Value "RootManageSharedAccessKey" `
                -Description "The name of the namespace access policy key that will be used during the deployment to fetch the connection string based on that key. ($($connectionObj.Name))"
            
            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$displayPreSuf')]"
            $apiObj.properties.parameterValues.connectionString = $apiObj.properties.parameterValues.connectionString.Replace("'##SUSCRIPTIONID##'", "parameters('$subPreSuf')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##NAMESPACE##'", "parameters('$objPreSuf')").Replace("'##KEYNAME##'", "parameters('$keyPreSuf')")
            
            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }

            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
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

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus, and that is using the classic connection string approach
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the ResourceGroup, Namespace, AccessKey
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Displayname is extracted from the Api Connection Object
--The displayname will be configured to be the same as the name of the connection
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject.AzAccount" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {
        
            # This should only handle the classic Servicebus connections based on ListKey
            if ($connectionObj.Value.connectionProperties.authentication.type -eq "ManagedServiceIdentity") { continue }
        
            $found = $true
        
            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json

            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.ConnectionString.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $subPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($connectionObj.Name)"
            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($connectionObj.Name)"
            $objPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"
            $keyPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Key" -Value "$($connectionObj.Name)"

            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$subPreSuf" `
                -Type "string" `
                -Value "[subscription().subscriptionId]" `
                -Description "The subscription where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$rgPreSuf" `
                -Type "string" `
                -Value "[resourceGroup().name]" `
                -Description "The resource group where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$objPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$keyPreSuf" `
                -Type "string" `
                -Value "RootManageSharedAccessKey" `
                -Description "The name of the namespace access policy key that will be used during the deployment to fetch the connection string based on that key. ($($connectionObj.Name))"
            
            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            $apiObj.properties.parameterValues.connectionString = $apiObj.properties.parameterValues.connectionString.Replace("'##SUSCRIPTIONID##'", "parameters('$subPreSuf')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##NAMESPACE##'", "parameters('$objPreSuf')").Replace("'##KEYNAME##'", "parameters('$keyPreSuf')")
            
            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }

            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
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

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus, and that is using the classic connection string approach
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the ResourceGroup, Namespace, AccessKey
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Displayname is extracted from the Api Connection Object
--The displayname will be configured to be the same as the name of the connection
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {
        
            # This should only handle the classic Servicebus connections based on ListKey
            if ($connectionObj.Value.connectionProperties.authentication.type -eq "ManagedServiceIdentity") { continue }
        
            $found = $true
        
            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.ConnectionString.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $subPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($connectionObj.Name)"
            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($connectionObj.Name)"
            $objPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"
            $keyPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Key" -Value "$($connectionObj.Name)"

            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$subPreSuf" `
                -Type "string" `
                -Value "[subscription().subscriptionId]" `
                -Description "The subscription where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$rgPreSuf" `
                -Type "string" `
                -Value "[resourceGroup().name]" `
                -Description "The resource group where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$objPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$keyPreSuf" `
                -Type "string" `
                -Value "RootManageSharedAccessKey" `
                -Description "The name of the namespace access policy key that will be used during the deployment to fetch the connection string based on that key. ($($connectionObj.Name))"
            
            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            $apiObj.properties.parameterValues.connectionString = $apiObj.properties.parameterValues.connectionString.Replace("'##SUSCRIPTIONID##'", "parameters('$subPreSuf')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##NAMESPACE##'", "parameters('$objPreSuf')").Replace("'##KEYNAME##'", "parameters('$keyPreSuf')")
            
            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }

            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
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

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.Advanced.AsArmObject.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus and is using the Managed Identity authentication scheme
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Namespace
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on the Managed Identity authentication
--Name & Displayname is extracted from the Api Connection Object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.Advanced.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.Advanced.AsArmObject.AzAccount" @parm -Action {
    Set-TaskWorkDirectory
    
    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {

            # This should only handle Managed Identity Servicebus connections
            if ($connectionObj.Value.connectionProperties.authentication.type -ne "ManagedServiceIdentity") { continue }

            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName
            $resName = $displayName #fallback default value

            if ($resObj.Properties.parameterValueSet.values.namespaceEndpoint.value -match "sb://(.*).servicebus.windows.net") {
                $resName = $Matches[1]
            }

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($connectionObj.Name)"
            $nsPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
                -Type "string" `
                -Value "$resName" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"

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
            $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value = $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value.Replace("'##NAMESPACE##'", "parameters('$nsPreSuf')")

            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }
            
            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
            $connectionObj.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType', subscription().subscriptionId, parameters('logicAppLocation'))]"
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

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.Advanced.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus and is using the Managed Identity authentication scheme
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Namespace
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on the Managed Identity authentication
--Name & Displayname is extracted from the Api Connection Object
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.Advanced.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.Advanced.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory
    
    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {

            # This should only handle Managed Identity Servicebus connections
            if ($connectionObj.Value.connectionProperties.authentication.type -ne "ManagedServiceIdentity") { continue }

            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Name
            $displayName = $resObj.Properties.DisplayName
            $resName = $displayName #fallback default value

            if ($resObj.Properties.parameterValueSet.values.namespaceEndpoint.value -match "sb://(.*).servicebus.windows.net") {
                $resName = $Matches[1]
            }

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($connectionObj.Name)"
            $nsPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
                -Type "string" `
                -Value "$resName" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"

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
            $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value = $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value.Replace("'##NAMESPACE##'", "parameters('$nsPreSuf')")

            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }
            
            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
            $connectionObj.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType', subscription().subscriptionId, parameters('logicAppLocation'))]"
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

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject.AzAccount.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus and is using the Managed Identity authentication scheme
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Namespace
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on the Managed Identity authentication
--Name & Displayname is extracted from the ConnectionName property
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject.AzAccount" @parm -Action {
    Set-TaskWorkDirectory
    
    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {

            # This should only handle Managed Identity Servicebus connections
            if ($connectionObj.Value.connectionProperties.authentication.type -ne "ManagedServiceIdentity") { continue }

            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)
            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName
            $resName = $resObj.Properties.DisplayName #fallback default value

            if ($resObj.Properties.parameterValueSet.values.namespaceEndpoint.value -match "sb://(.*).servicebus.windows.net") {
                $resName = $Matches[1]
            }

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            $nsPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
                -Type "string" `
                -Value "$resName" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value = $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value.Replace("'##NAMESPACE##'", "parameters('$nsPreSuf')")

            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }
            
            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
            $connectionObj.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType', subscription().subscriptionId, parameters('logicAppLocation'))]"
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

#Original file: Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject.AzCli.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus and is using the Managed Identity authentication scheme
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Namespace
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on the Managed Identity authentication
--Name & Displayname is extracted from the ConnectionName property
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject.AzCli" @parm -Action {
    Set-TaskWorkDirectory
    
    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/servicebus*") {

            # This should only handle Managed Identity Servicebus connections
            if ($connectionObj.Value.connectionProperties.authentication.type -ne "ManagedServiceIdentity") { continue }

            $found = $true

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            $resObj = az rest --url $uri | ConvertFrom-Json
            
            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName
            $resName = $resObj.Properties.DisplayName #fallback default value

            if ($resObj.Properties.parameterValueSet.values.namespaceEndpoint.value -match "sb://(.*).servicebus.windows.net") {
                $resName = $Matches[1]
            }

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.SB.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            $nsPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
                -Type "string" `
                -Value "$resName" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value = $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value.Replace("'##NAMESPACE##'", "parameters('$nsPreSuf')")

            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }
            
            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$idPreSuf'))]"
            $connectionObj.Value.connectionName = "[parameters('$idPreSuf')]"
            $connectionObj.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType', subscription().subscriptionId, parameters('logicAppLocation'))]"
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

#Original file: Set-Arm.Connections.ManagedApis.Storage.BlobOrFile.ListKey.Advanced.AsArmObject.task.ps1
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

#Original file: Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzAccount.task.ps1
$parm = @{
  Description = @"
"@
  Alias       = "Arm.Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzAccount" @parm -Action {
  Set-TaskWorkDirectory

  $armObj = Get-TaskWorkObject

  $subLocal = (Get-AzContext).Subscription.Id

  if ($SubscriptionId) {
    $subLocal = $SubscriptionId
  }
   
  $uri = "/subscriptions/$subLocal/resourceGroups/$ResourceGroup/providers/Microsoft.Logic/workflows/$Name/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview"

  $res = Invoke-AzRestMethod -Path $uri -Method GET
  $diagSettings = @($res.Content | ConvertFrom-Json | Select-Object -ExpandProperty Value)

  $counter = 0

  foreach ($diag in $diagSettings) {
    if ([System.String]::IsNullOrEmpty($diag.properties.workspaceId)) {
      continue
    }

    $orgName = $diag.name
    $orgWorkspace = $diag.properties.workspaceId.Split("/") | Select-Object -Last 1

    $counter += 1

    $parmName = "diagnostic$($counter.ToString().PadLeft(3, "0"))_Name"
    $parmWorkspace = "diagnostic$($counter.ToString().PadLeft(3, "0"))_WorkspaceId"

    $diag.properties.workspaceId = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OperationalInsights/workspaces/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"
        
    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
      -Type "string" `
      -Value "$orgName" `
      -Description "The name of diagnostic setting / profile for the Logic App."

    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmWorkspace `
      -Type "string" `
      -Value "$orgWorkspace" `
      -Description "The name / id of the Log Analytics (Workspace) that is referenced by the Logic App and its diagnostic settings."
      
    # Fetch base template
    $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
    $diagObj = Get-Content -Path "$pathArms\DIAG.Workspace.Simple.json" -Raw | ConvertFrom-Json
    
    $diagObj.Name = "[parameters('$parmName')]"
    $diagObj.properties.workspaceId = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OperationalInsights/workspaces/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmWorkspace'))]"
    $diagObj.properties.logs = $diag.properties.logs
    $diagObj.properties.metrics = $diag.properties.metrics
    $armObj.resources += $diagObj

  }

  Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzCli.task.ps1
$parm = @{
  Description = @"
"@
  Alias       = "Arm.Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzCli"
}

Task -Name "Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzCli" @parm -Action {
  Set-TaskWorkDirectory

  $armObj = Get-TaskWorkObject

  $subLocal = (az account show | ConvertFrom-Json).Id

  if ($SubscriptionId) {
    $subLocal = $SubscriptionId
  }
   
  $uri = "/subscriptions/$subLocal/resourceGroups/$ResourceGroup/providers/Microsoft.Logic/workflows/$Name/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview"

  $res = az rest --url $uri | ConvertFrom-Json
  
  $diagSettings = @($res.Content | ConvertFrom-Json | Select-Object -ExpandProperty Value)

  $counter = 0

  foreach ($diag in $diagSettings) {
    if ([System.String]::IsNullOrEmpty($diag.properties.workspaceId)) {
      continue
    }

    $orgName = $diag.name
    $orgWorkspace = $diag.properties.workspaceId.Split("/") | Select-Object -Last 1

    $counter += 1

    $parmName = "diagnostic$($counter.ToString().PadLeft(3, "0"))_Name"
    $parmWorkspace = "diagnostic$($counter.ToString().PadLeft(3, "0"))_WorkspaceId"

    $diag.properties.workspaceId = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OperationalInsights/workspaces/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"
        
    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
      -Type "string" `
      -Value "$orgName" `
      -Description "The name of diagnostic setting / profile for the Logic App."

    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmWorkspace `
      -Type "string" `
      -Value "$orgWorkspace" `
      -Description "The name / id of the Log Analytics (Workspace) that is referenced by the Logic App and its diagnostic settings."
      
    # Fetch base template
    $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
    $diagObj = Get-Content -Path "$pathArms\DIAG.Workspace.Simple.json" -Raw | ConvertFrom-Json
    
    $diagObj.Name = "[parameters('$parmName')]"
    $diagObj.properties.workspaceId = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OperationalInsights/workspaces/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmWorkspace'))]"
    $diagObj.properties.logs = $diag.properties.logs
    $diagObj.properties.metrics = $diag.properties.metrics
    $armObj.resources += $diagObj

  }

  Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.FunctionApp.IdFormatted.Advanced.AsParameter.task.ps1
$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.FunctionApp.IdFormatted.Advanced.AsParameter"
}

Task -Name "Set-Arm.FunctionApp.IdFormatted.Advanced.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Function" }


    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.function.id -like "*``[*``]*")) {
            if ($item.Value.inputs.function.id -match "/subscriptions/.*/resourceGroups/(.*)/providers/Microsoft.Web/sites/(.*)/functions/(.*)") {
                $counter += 1
                $parmName = "functionApp$($counter.ToString().PadLeft(3, "0"))"
                $parmGroup = "functionApp$($counter.ToString().PadLeft(3, "0"))ResourceGroup"

                $functionGroup = $Matches[1]
                $functionName = $Matches[2]
                
                $item.Value.inputs.function.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/sites/{2}/functions/$($Matches[3])', subscription().subscriptionId, parameters('$parmGroup'), parameters('$parmName'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$functionName" `
                    -Description "The name / id of the FunctionApp that is referenced by the Logic App."

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmGroup `
                    -Type "string" `
                    -Value $functionGroup `
                    -Description "The resource group where the FunctionApp that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.FunctionApp.IdFormatted.Advanced.WithMethod.AsParameter.task.ps1
$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.FunctionApp.IdFormatted.Advanced.WithMethod.AsParameter"
}

Task -Name "Set-Arm.FunctionApp.IdFormatted.Advanced.WithMethod.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Function" }


    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.function.id -like "*``[*``]*")) {
            if ($item.Value.inputs.function.id -match "/subscriptions/.*/resourceGroups/(.*)/providers/Microsoft.Web/sites/(.*)/functions/(.*)") {
                $counter += 1
                $parmName = "functionApp$($counter.ToString().PadLeft(3, "0"))"
                $parmGroup = "functionApp$($counter.ToString().PadLeft(3, "0"))ResourceGroup"
                $parmMethod = "functionApp$($counter.ToString().PadLeft(3, "0"))Method"

                $functionGroup = $Matches[1]
                $functionName = $Matches[2]
                $functionMethod = $Matches[3]

                $item.Value.inputs.function.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/sites/{2}/functions/{3})', subscription().subscriptionId, parameters('$parmGroup'), parameters('$parmName'), parameters('$parmMethod'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$functionName" `
                    -Description "The name / id of the FunctionApp that is referenced by the Logic App."

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmGroup `
                    -Type "string" `
                    -Value $functionGroup `
                    -Description "The resource group where the FunctionApp that is referenced by the Logic App."

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmMethod `
                    -Type "string" `
                    -Value "$functionMethod" `
                    -Description "The name the method exposed by the FunctionApp that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.FunctionApp.IdFormatted.Simple.AsParameter.task.ps1
$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.FunctionApp.IdFormatted.Simple.AsParameter"
}

Task -Name "Set-Arm.FunctionApp.IdFormatted.Simple.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Function" }


    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.function.id -like "*``[*``]*")) {
            if ($item.Value.inputs.function.id -match "/sites/(.*)/functions/(.*)") {
                $counter += 1
                $parmName = "functionApp$($counter.ToString().PadLeft(3, "0"))"

                $functionName = $Matches[1]
                $item.Value.inputs.function.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/sites/{2}/functions/$($Matches[2])', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$functionName" `
                    -Description "The name / id of the FunctionApp that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.FunctionApp.IdFormatted.Simple.WithMethod.AsParameter.task.ps1
$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.FunctionApp.IdFormatted.Simple.WithMethod.AsParameter"
}

Task -Name "Set-Arm.FunctionApp.IdFormatted.Simple.WithMethod.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Function" }


    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.function.id -like "*``[*``]*")) {
            if ($item.Value.inputs.function.id -match "/sites/(.*)/functions/(.*)") {
                $counter += 1
                $parmName = "functionApp$($counter.ToString().PadLeft(3, "0"))"
                $parmMethod = "functionApp$($counter.ToString().PadLeft(3, "0"))Method"

                $functionName = $Matches[1]
                $functionMethod = $Matches[2]

                $item.Value.inputs.function.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/sites/{2}/functions/{3}}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'), parameters('$parmMethod'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$functionName" `
                    -Description "The name / id of the FunctionApp that is referenced by the Logic App."

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmMethod `
                    -Type "string" `
                    -Value "$functionMethod" `
                    -Description "The name the method exposed by the FunctionApp that is referenced by the Logic App."
                    
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsParameter.task.ps1
$parm = @{
    Description = @"
Creates an Arm parameter: integrationAccount
-Set the default value to the original name, extracted from integrationAccount.Id
Creates an Arm parameter: integrationAccountResourceGroup
-Set the default value to the original resource group, extracted from integrationAccount.Id
Sets the value of the integrationAccount.Id: [format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId, parameters('integrationAccountResourceGroup'), parameters('integrationAccount'))]
"@
    Alias       = "Arm.Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsParameter"
}

Task -Name "Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.integrationAccount.id) {
        if ($armObj.resources[0].properties.integrationAccount.id -match "resourceGroups/(.*)/providers") {
            
            $integrationAccountName = $armObj.resources[0].properties.integrationAccount.id.Split("/") | Select-Object -Last 1
            $armObj.resources[0].properties.integrationAccount.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId, parameters('integrationAccountResourceGroup'), parameters('integrationAccount'))]"

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

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsVariable.task.ps1
$parm = @{
    Description = @"
Creates an Arm variable: integrationAccount
-Set the value to the original name, extracted from integrationAccount.Id
Creates an Arm variable: integrationAccountResourceGroup
-Set the value to the original resource group, extracted from integrationAccount.Id
Sets the value of the integrationAccount.Id: [format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId,variables('integrationAccountResourceGroup'),variables('integrationAccount'))]
"@
    Alias       = "Arm.Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsVariable"
}

Task -Name "Set-Arm.IntegrationAccount.IdFormatted.Advanced.AsVariable" @parm -Action {
    Set-TaskWorkDirectory
    
    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.integrationAccount.id) {
        if ($armObj.resources[0].properties.integrationAccount.id -match "resourceGroups/(.*)/providers") {

            $integrationAccountName = $armObj.resources[0].properties.integrationAccount.id.Split("/") | Select-Object -Last 1

            $armObj.resources[0].properties.integrationAccount.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId,variables('integrationAccountResourceGroup'),variables('integrationAccount'))]"

            $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("name")
            $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("type")

            $armObj = Add-ArmVariable -InputObject $armObj -Name "integrationAccount" -Value "$integrationAccountName"
            $armObj = Add-ArmVariable -InputObject $armObj -Name "integrationAccountResourceGroup" -Value "$($Matches[1])"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter.task.ps1
$parm = @{
    Description = @"
Creates an Arm parameter: integrationAccount
-Set the default value to the original name, extracted from integrationAccount.Id
Sets the value of the integrationAccount.Id: [format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId, resourceGroup().name, parameters('integrationAccount'))]
"@
    Alias       = "Arm.Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter"
}

Task -Name "Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.integrationAccount.id) {
        $integrationAccountName = $armObj.resources[0].properties.integrationAccount.id.Split("/") | Select-Object -Last 1
        $armObj.resources[0].properties.integrationAccount.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}', subscription().subscriptionId, resourceGroup().name, parameters('integrationAccount'))]"

        $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("name")
        $armObj.resources[0].properties.integrationAccount.PsObject.Properties.Remove("type")

        $armObj = Add-ArmParameter -InputObject $armObj -Name "integrationAccount" `
            -Type "string" `
            -Value "$integrationAccountName" `
            -Description "The name / id of the Integration Account that is being utilized by the Logic App."
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.IntegrationAccount.IdFormatted.Simple.AsVariable.task.ps1
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

#Original file: Set-Arm.Location.AsResourceGroup.AsParameter.task.ps1
$parm = @{
    Description = @"
Creates an Arm parameter: logicAppLocation
-Set the default value to: [resourceGroup().location]
This is the current best practice, and will supress any validation errors in the different tools that exists
"@
    Alias       = "Arm.Set-Arm.Location.AsResourceGroup.AsParameter"
}

Task -Name "Set-Arm.Location.AsResourceGroup.AsParameter" @parm -Action {
    Set-TaskWorkDirectory
    
    $armObj = Get-TaskWorkObject

    $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppLocation" `
        -Type "string" `
        -Value "[resourceGroup().location]" `
        -Description "Location of the Logic App. Best practice recommendation is to make this depending on the Resource Group and its location."
    $armObj.resources[0].location = "[parameters('logicAppLocation')]"

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.LogicApp.Name.AsParameter.task.ps1
$parm = @{
    Description = @"
Creates an Arm parameter: logicAppName
-Sets the default value to the original name
"@
    Alias       = "Arm.Set-Arm.LogicApp.Name.AsParameter"
}

Task -Name "Set-Arm.LogicApp.Name.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject
    $orgName = $armObj.resources[0].name
    
    $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppName" `
        -Type "string" `
        -Value "$orgName" `
        -Description "Name of the Logic App. Makes it possible to override the name at deploy time."
    $armObj.resources[0].name = "[parameters('logicAppName')]"

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.LogicApp.Parm.AsParameter.task.ps1
$parm = @{
    Description = @"
Loops all internal / inner LogicApp parm (parameters)
-Creates an Arm parameter, with prefix & suffix
--Sets the default value (Arm parameter) to the original value from the parm
-Sets the default value (LogicApp parm) to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.LogicApp.Parm.AsParameter"
}

Task -Name "Set-Arm.LogicApp.Parm.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.definition.parameters.PsObject.Properties | ForEach-Object {
        if ($_.Name -ne '$connections') {
            $namePreSuf = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value $_.Name

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
                -Type "$($_.Value.type)" `
                -Value $($_.Value.defaultValue) `
                -Description "A parameter that is defined inside in the Logic App. Not to be confused with parameters for the Arm Template deployment."
            $_.Value.defaultValue = "[parameters('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.LogicApp.Parm.AsVariable.task.ps1
$parm = @{
    Description = @"
Loops all internal / inner LogicApp parm (parameters)
-Creates an Arm variable, with prefix & suffix
--Sets the value (Arm variable) to the original value from the parm
-Sets the default value (LogicApp parm) to: [variables('XYZ')]
"@
    Alias       = "Arm.Set-Arm.LogicApp.Parm.AsVariable"
}

Task -Name "Set-Arm.LogicApp.Parm.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.definition.parameters.PsObject.Properties | ForEach-Object {
        if ($_.Name -ne '$connections') {
            $namePreSuf = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value $_.Name

            $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $($_.Value.defaultValue)
            $_.Value.defaultValue = "[variables('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.LogicApp.State.AsParameter.task.ps1
$parm = @{
    Description = @"
Creates an Arm parameter: logicAppState
-Sets the default value to the original state of the Logic App
"@
    Alias       = "Arm.Set-Arm.LogicApp.State.AsParameter"
}

Task -Name "Set-Arm.LogicApp.State.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject
    $orgValue = $armObj.resources[0].properties.state
    
    $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppState" `
        -Type "string" `
        -Value "$orgValue" `
        -Description "State of the Logic App when is being deployed. Makes it possible to override the name at deploy time."
    $armObj.resources[0].properties.state = "[parameters('logicAppState')]"

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Tags.AsParameter.task.ps1
$parm = @{
    Description = @"
Loops all tags
-Creates an Arm parameter, with prefix & suffix
--Sets the default value (Arm parameter) to the original value from the tag
-Sets the value (Tag) to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Tags.AsParameter"
}

Task -Name "Set-Arm.Tags.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].tags.PsObject.Properties | ForEach-Object {
        $namePreSuf = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value $_.Name

        $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
            -Type "string" `
            -Value "$($_.Value)" `
            -Description "Tag that is searchable inside the Azure platform, either with the GUI (portal.azure.com) or with scripting tools."

        $_.Value = "[parameters('$namePreSuf')]"
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Tags.AsVariable.task.ps1
$parm = @{
    Description = @"
Loops all tags
-Creates an Arm variable, with prefix & suffix
--Sets the value (Arm variable) to the original value from the tag
-Sets the value (Tag) to: [variables('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Tags.AsVariable"
}

Task -Name "Set-Arm.Tags.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].tags.PsObject.Properties | ForEach-Object {
        $namePreSuf = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value $($_.Name)

        $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $($_.Value)
        $_.Value = "[variables('$namePreSuf')]"
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter.task.ps1
$parm = @{
    Description = @"
    Creates an Arm parameter: trigger_EvalFrequency
    -Sets the default value to the original value, extracted from evaluatedRecurrence.frequency
    -Sets the evaluatedRecurrence.frequency value to: [parameters('trigger_EvalFrequency')]
    Creates an Arm parameter: trigger_EvalInterval
    -Set the default value to the original value, extracted from evaluatedRecurrence.interval
    -Sets the evaluatedRecurrence.interval value to: [parameters('trigger_EvalInterval')]
"@
    Alias       = "Arm.Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter"
}

Task -Name "Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -in @("ApiConnection", "Recurrence") -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence) {

        $frequencyPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalFrequency"
        $intervalPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalInterval"
        $startTimePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalStartTime"
        $timeZonePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "EvalTimeZone"

        if ($null -eq @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.evaluatedRecurrence) {
            # Create the evaluatedRecurrence property if it does not exist
            @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value | Add-Member -MemberType NoteProperty -Name "evaluatedRecurrence" -Value $([ordered]@{
                    frequency = "Minute";
                    interval  = 1;
                })
        }

        # Handle the frequency property
        $orgFrequency = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.frequency
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$frequencyPreSuf" `
            -Type "string" `
            -Value $orgFrequency `
            -Description "The frequency used for the trigger to evalutate."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.frequency = "[parameters('$frequencyPreSuf')]"
        
        # Handle the interval property
        $orgInterval = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.interval
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$intervalPreSuf" `
            -Type "int" `
            -Value $orgInterval `
            -Description "The interval used for the trigger to evalutate."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.interval = "[parameters('$intervalPreSuf')]"

        # Handle the StartTime property
        $orgStartTime = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.startTime
        if (-not ($null -eq $orgStartTime)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$startTimePreSuf" `
                -Type "string" `
                -Value $orgStartTime `
                -Description "The start time used for the trigger to evalutate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.startTime = "[parameters('$startTimePreSuf')]"
        }

        # Handle the TimeZone property
        $orgTimeZone = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.timeZone
        if (-not ($null -eq $orgTimeZone)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$timeZonePreSuf" `
                -Type "string" `
                -Value $orgTimeZone `
                -Description "The time zone used for the trigger to evalutate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.evaluatedRecurrence.timeZone = "[parameters('$timeZonePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter.task.ps1
$parm = @{
    Description = @"
Creates an Arm parameter: trigger_Frequency
-Sets the default value to the original value, extracted from recurrence.frequency
-Sets the recurrence.frequency value to: [parameters('trigger_Frequency')]
Creates an Arm parameter: trigger_Interval
-Set the default value to the original value, extracted from recurrence.interval
-Sets the recurrence.interval value to: [parameters('trigger_Interval')]
"@
    Alias       = "Arm.Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter"
}

Task -Name "Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    if ($armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.type -in @("ApiConnection", "Recurrence") -and
        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence) {

        $frequencyPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Frequency"
        $intervalPreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "Interval"
        $startTimePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "StartTime"
        $timeZonePreSuf = Format-Name -Type "Trigger" -Prefix $Trigger_Prefix -Suffix $Trigger_Suffix -Value "TimeZone"

        # Handle the Frequency property
        $orgFrequency = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.frequency
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$frequencyPreSuf" `
            -Type "string" `
            -Value $orgFrequency `
            -Description "The frequency used for the trigger to run."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.frequency = "[parameters('$frequencyPreSuf')]"
        
        # Handle the Interval property
        $orgInterval = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.interval
        $armObj = Add-ArmParameter -InputObject $armObj -Name "$intervalPreSuf" `
            -Type "int" `
            -Value $orgInterval `
            -Description "The interval used for the trigger to run."

        $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.interval = "[parameters('$intervalPreSuf')]"

        # Handle the StartTime property
        $orgStartTime = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.startTime
        if (-not ($null -eq $orgStartTime)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$startTimePreSuf" `
                -Type "string" `
                -Value $orgStartTime `
                -Description "The start time used for the trigger to evalutate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.startTime = "[parameters('$startTimePreSuf')]"
        }

        # Handle the TimeZone property
        $orgTimeZone = $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.timeZone
        if (-not ($null -eq $orgTimeZone)) {
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$timeZonePreSuf" `
                -Type "string" `
                -Value $orgTimeZone `
                -Description "The time zone used for the trigger to evalutate."

            $armObj.resources[0].properties.definition.triggers.PsObject.Properties.Value.recurrence.timeZone = "[parameters('$timeZonePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Trigger.Cds.AsParameter.task.ps1
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
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

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

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.UserAssignedIdentities.ResourceId.AsParameter.task.ps1
$parm = @{
    Description = @"
Creates an Arm parameter: userAssignedIdentityName
-Sets the default value to the original name, extracted from Microsoft.ManagedIdentity/userAssignedIdentities/XYZ
Sets the value for all references to: [resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('UserAssignedIdentityName'))]
"@
    Alias       = "Arm.Set-Arm.UserAssignedIdentities.ResourceId.AsParameter"
}

Task -Name "Set-Arm.UserAssignedIdentities.ResourceId.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $raw = Get-TaskWorkRaw

    if ($raw -match '"/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ManagedIdentity/userAssignedIdentities/(.*)"') {
        $temp = $raw.Replace($Matches[0], "`"[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('UserAssignedIdentityName'))]`"")

        $armObj = $temp | ConvertFrom-Json

        $armObj = Add-ArmParameter -InputObject $armObj -Name "userAssignedIdentityName" `
            -Type "string" `
            -Value $Matches[1] `
            -Description "The name of the Managed Identity (UserAssignedIdentity) that will be utilized inside of the Logic App. Should be name of the object and not the id."
    }
    else {
        $armObj = $raw | ConvertFrom-Json
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.UserAssignedIdentities.ResourceId.AsVariable.task.ps1
$parm = @{
    Description = @"
Creates an Arm variable: userAssignedIdentityName
-Sets the default value to the original name, extracted from Microsoft.ManagedIdentity/userAssignedIdentities/XYZ
Sets the value for all references to: [resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', variables('UserAssignedIdentityName'))]
"@
    Alias       = "Arm.Set-Arm.UserAssignedIdentities.ResourceId.AsVariable"
}

Task -Name "Set-Arm.UserAssignedIdentities.ResourceId.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $raw = Get-TaskWorkRaw

    if ($raw -match '"/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ManagedIdentity/userAssignedIdentities/(.*)"') {
        $temp = $raw.Replace($Matches[0], "`"[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', variables('UserAssignedIdentityName'))]`"")

        $armObj = $temp | ConvertFrom-Json

        $armObj = Add-ArmVariable -InputObject $armObj -Name "userAssignedIdentityName" -Value $Matches[1]
    }
    else {
        $armObj = $raw | ConvertFrom-Json
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Workflow.IdFormatted.Simple.AsParameter.task.ps1
$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.Workflow.IdFormatted.Simple.AsParameter"
}

Task -Name "Set-Arm.Workflow.IdFormatted.Simple.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Workflow" }

    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.host.workflow.id -like "*``[*``]*")) {

            if ($item.Value.inputs.host.workflow.id -match "/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Logic/workflows/(.*)") {
                $counter += 1
                $parmName = "workFlowId$($counter.ToString().PadLeft(3, "0"))"

                $orgName = $Matches[1]
                $item.Value.inputs.host.workflow.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/workflows/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$orgName" `
                    -Description "The name / id of the WorkFlow (LogicApp) that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Arm.Workflow.IdFormatted.Simple.WithTrigger.AsParameter.task.ps1
$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.Workflow.IdFormatted.Simple.WithTrigger.AsParameter"
}

Task -Name "Set-Arm.Workflow.IdFormatted.Simple.WithTrigger.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Workflow" }

    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.host.workflow.id -like "*``[*``]*")) {

            if ($item.Value.inputs.host.workflow.id -match "/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Logic/workflows/(.*)") {
                $counter += 1
                $parmName = "workFlowId$($counter.ToString().PadLeft(3, "0"))"
                $parmTrigger = "workFlowId$($counter.ToString().PadLeft(3, "0"))Trigger"

                $orgName = $Matches[1]
                $item.Value.inputs.host.workflow.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/workflows/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$orgName" `
                    -Description "The name / id of the WorkFlow (LogicApp) that is referenced by the Logic App."

                $orgValue = $item.Value.inputs.host.triggerName
                $item.Value.inputs.host.triggerName = "[parameters('$parmTrigger')]"
                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmTrigger `
                    -Type "string" `
                    -Value "$orgValue" `
                    -Description "The name the method exposed by the FunctionApp that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Set-Raw.Actions.Http.Audience.AsParm.task.ps1
$parm = @{
    Description = @"
Loops all actions
-Identifies all HTTP
--Creates a LogicApp parm (parameter), with prefix & suffix
---Sets the default value (LogicApp parm) to the original value, extracted from authentication.audience
---Sets the authentication.audience value to: @{parameters('XYZ')}
"@
    Alias       = "Raw.Set-Raw.Actions.Http.Audience.AsParm"
}

Task -Name "Set-Raw.Actions.Http.Audience.AsParm" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    
    $counter = 0
    $actions = $lgObj.properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Http" }

    foreach ($item in $actions) {
        if ($item.Value.inputs.authentication -and (-not ($item.Value.inputs.authentication.audience -like "*parameters('*')*"))) {
            if (-not [System.String]::IsNullOrEmpty($item.Value.inputs.authentication.audience)) {
                $counter += 1
                            
                $orgAudience = $item.Value.inputs.authentication.audience
                $parmName = "EndpointAudience$($counter.ToString().PadLeft(3, "0"))"
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value $orgAudience
            
                $item.Value.inputs.authentication.audience = "@{parameters('$parmName')}"
            }
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.Actions.Http.Uri.AsParm.task.ps1
$parm = @{
    Description = @"
Loops all actions
-Identifies all HTTP
--Creates a LogicApp parm (parameter), with prefix & suffix
---Sets the default value (LogicApp parm) to the original value, extracted from inputs.uri
---Sets the inputs.uri value to: @{parameters('XYZ')}
"@
    Alias       = "Raw.Set-Raw.Actions.Http.Uri.AsParm"
}

Task -Name "Set-Raw.Actions.Http.Uri.AsParm" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    
    $counter = 0
    $actions = $lgObj.properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Http" }

    foreach ($item in $actions) {
        if ($item.Value.inputs.uri -like "*http*") {
            if ($item.Value.inputs.uri -match "^.+?[^\/:](?=[?\/]|$)" -and (-not ($item.Value.inputs.uri -like "*parameters('*')*"))) {
                $counter += 1
                            
                $parmName = "EndpointUri$($counter.ToString().PadLeft(3, "0"))"
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value $Matches[0]

                $item.Value.inputs.uri = $item.Value.inputs.uri.Replace($Matches[0], "@{parameters('$parmName')}")
            }
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.Actions.Servicebus.Queue.AsParm.task.ps1
$parm = @{
    Description = @"
Loops all actions
-Identifies all Servicebus
--Creates a LogicApp parm (parameter), with prefix & suffix
---Sets the default value (LogicApp parm) to the original value, extracted from inputs.path
---Sets the inputs.path value to: ...encodeURIComponent(parameters('XYZ')))}/messages/...
"@
    Alias       = "Raw.Set-Arm.Connections.ManagedApis.AsParameter"
}

Task -Name "Set-Raw.Actions.Servicebus.Queue.AsParm" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    
    $counter = 0

    $actions = $lgObj.properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "ApiConnection" }

    foreach ($item in $actions) {
        if ($item.Value.inputs.path -like "*messages*") {
            if (-not ($item.Value.inputs.path -like "*parameters('*')*")) {

                if ($item.Value.inputs.path -match "'(.*)'") {
                    $counter += 1
                                
                    $parmName = "Queue$($counter.ToString().PadLeft(3, "0"))"
                    $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                        -Type "string" `
                        -Value "$($Matches[1])"
            
                    $item.Value.inputs.path = $item.Value.inputs.path.Replace($Matches[0], "parameters('$parmName')")
                }
            }
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.ApiVersion.task.ps1
$parm = @{
    Description = @"
Creates / assigns the ApiVersion property in the LogicApp json structure
-Sets the value to: `$ApiVersion (property passed as argument)
"@
    Alias       = "Raw.Set-Raw.ApiVersion"
}

Task -Name "Set-Raw.ApiVersion" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    $lgObj.apiVersion = $ApiVersion

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.Connections.ManagedApis.Id.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Sets connectionId to the name of the connection, extracted from the connectionName
"@
    Alias       = "Raw.Set-Raw.Connections.ManagedApis.Id"
}

Task -Name "Set-Raw.Connections.ManagedApis.Id" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $_.Value.connectionId = $_.Value.connectionId.Replace($conName, $_.Value.connectionName)
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.Connections.ManagedApis.Name.task.ps1
$parm = @{
    Description = @"
Loops all `$connections children
-Sets connectionName to the name of the connection, extracted from the connectionId
"@
    Alias       = "Raw.Set-Raw.Connections.ManagedApis.Name"
}

Task -Name "Set-Raw.Connections.ManagedApis.Name" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $_.Value.connectionName = $conName
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.State.Disabled.task.ps1
$parm = @{
    Description = @"
Creates / assigns the state property in the LogicApp json structure
-Sets the value to: Disabled
"@
    Alias       = "Raw.Set-Raw.State.Disabled"
}

Task -Name "Set-Raw.State.Disabled" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    $lgObj.properties.state = "Disabled"
    
    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.State.Enabled.task.ps1
$parm = @{
    Description = @"
Creates / assigns the state property in the LogicApp json structure
-Sets the value to: Enabled
"@
    Alias       = "Raw.Set-Raw.State.Enabled"
}

Task -Name "Set-Raw.State.Enabled" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    $lgObj.properties.state = "Enabled"
    
    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.Trigger.Servicebus.Queue.AsParm.task.ps1
$parm = @{
    Description = @"
Creates a LogicApp parm (parameter): TriggerQueue
-Sets the default value to the original value, extracted from inputs.path
--Sets the inputs.path value to: ...encodeURIComponent(parameters('TriggerQueue')))}/messages/...
"@
    Alias       = "Raw.Set-Raw.Trigger.Servicebus.Queue.AsParm"
}

Task -Name "Set-Raw.Trigger.Servicebus.Queue.AsParm" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject

    if ($lgObj.properties.definition.triggers.PsObject.Properties.Value.type -eq "ApiConnection" -and
        $lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path -like "*messages*") {
            
        if (-not ($lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path -like "*parameters('*')*")) {
            if ($lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path -match "'(.*)'") {
                
                $parmName = "TriggerQueue"
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value "$($Matches[1])"

                $lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path = $lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path.Replace($Matches[0], "parameters('$parmName')")
            }
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Set-Raw.UserAssignedIdentities.EmptyValue.task.ps1
$parm = @{
    Description = @"
Loops all identity childs, which are UserAssigned
-Sets the value to an empty object
"@
    Alias       = "Raw.Set-Raw.UserAssignedIdentities.EmptyValue"
}

Task -Name "Set-Raw.UserAssignedIdentities.EmptyValue" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.identity | Where-Object type -eq UserAssigned | ForEach-Object {
        Foreach ($item in $_.userAssignedIdentities.PsObject.Properties) {
            $item.Value = @{}
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Sort-Arm.Parameter.task.ps1
$parm = @{
    Description = @"
Loops all Arm parameters
Identity known parameters and gives them a sorting value
-Custom parameters are assigned a "neutral" sorting value
Sorts parameters and re-assign them to the Arm template
"@
    Alias       = "Arm.Sort-Arm.Parameter"
}

Task -Name "Sort-Arm.Parameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $PrefixConnection = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
    $connectionPattern = Format-Name -Type "Connection" -Prefix $PrefixConnection -Value "*"

    $PrefixParm = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.parm.prefix
    $parmPattern = Format-Name -Type "Parm" -Prefix $PrefixParm -Value "*"

    $PrefixTag = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.tag.prefix
    $tagPattern = Format-Name -Type "Tag" -Prefix $PrefixTag -Value "*"
    
    $sorted = @(foreach ($item in $armObj.parameters.PsObject.Properties) {
            switch -Wildcard ($item.Name) {
                "logicApp*" { [PsCustomObject]@{Sort = 0; Name = $item.Name; Value = $item.Value } }
                "trigger*" { [PsCustomObject]@{Sort = 100; Name = $item.Name; Value = $item.Value } }
                "userAssignedIdentityName" { [PsCustomObject]@{Sort = 200; Name = $item.Name; Value = $item.Value } }
                "$connectionPattern" { [PsCustomObject]@{Sort = 300; Name = $item.Name; Value = $item.Value } }
                "$parmPattern" { [PsCustomObject]@{Sort = 100000; Name = $item.Name; Value = $item.Value } }
                "$tagPattern" { [PsCustomObject]@{Sort = 1000000; Name = $item.Name; Value = $item.Value } }
                default { [PsCustomObject]@{Sort = 1000; Name = $item.Name; Value = $item.Value } }
            }
        }) | Sort-Object -Property Sort

    $orderedParms = [ordered]@{}

    $groups = $sorted | Group-Object -Property Sort

    foreach ($item in $groups) {
        $item.Group | Sort-Object -Property Name | ForEach-Object {
            $orderedParms."$($_.Name)" = $_.Value
        }
    }

    $armObj.parameters = [PsCustomObject]$orderedParms

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Sort-Arm.Variable.task.ps1
$parm = @{
    Description = @"
Loops all Arm variables
Identity known variables and gives them a sorting value
-Custom variables are assigned a "neutral" sorting value
Sorts variables and re-assign them to the Arm template
"@
    Alias       = "Arm.Sort-Arm.Variable"
}

Task -Name "Sort-Arm.Variable" @parm -Action {
    Set-TaskWorkDirectory
    
    $armObj = Get-TaskWorkObject

    $connectionPattern = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value "*"
    $parmPattern = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value "*"
    $tagPattern = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value "*"

    $sorted = @(foreach ($item in $armObj.variables.PsObject.Properties) {
            switch -Wildcard ($item.Name) {
                "logicApp*" { [PsCustomObject]@{Sort = 0; Name = $item.Name; Value = $item.Value } }
                "trigger*" { [PsCustomObject]@{Sort = 100; Name = $item.Name; Value = $item.Value } }
                "userAssignedIdentityName" { [PsCustomObject]@{Sort = 200; Name = $item.Name; Value = $item.Value } }
                "$connectionPattern" { [PsCustomObject]@{Sort = 300; Name = $item.Name; Value = $item.Value } }
                "$parmPattern" { [PsCustomObject]@{Sort = 100000; Name = $item.Name; Value = $item.Value } }
                "$tagPattern" { [PsCustomObject]@{Sort = 1000000; Name = $item.Name; Value = $item.Value } }
                default { [PsCustomObject]@{Sort = 1000; Name = $item.Name; Value = $item.Value } }
            }
        }) | Sort-Object -Property Sort

    $orderedParms = [ordered]@{}

    $groups = $sorted | Group-Object -Property Sort

    foreach ($item in $groups) {
        $item.Group | Sort-Object -Property Name | ForEach-Object {
            $orderedParms."$($_.Name)" = $_.Value
        }
    }

    $armObj.variables = [PsCustomObject]$orderedParms

    Out-TaskFileArm -InputObject $armObj
}

#Original file: Sort-Raw.LogicApp.Parm.task.ps1
$parm = @{
    Description = @"
Loops all LogicApp parm (parameter)
Sorts parms (parameters) and re-assign them to the Logic App json structure
"@
    Alias       = "Raw.Sort-Raw.LogicApp.Parm"
}

Task -Name "Sort-Raw.LogicApp.Parm" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    
    $sorted = @(foreach ($item in $lgObj.properties.definition.parameters.PsObject.Properties) {
            switch -Wildcard ($item.Name) {
                '$connections' { [PsCustomObject]@{Sort = 0; Name = $item.Name; Value = $item.Value } }
                default { [PsCustomObject]@{Sort = 1000; Name = $item.Name; Value = $item.Value } }
            }
        }) | Sort-Object -Property Sort

    $orderedParms = [ordered]@{}

    $groups = $sorted | Group-Object -Property Sort

    foreach ($item in $groups) {
        $item.Group | Sort-Object -Property Name | ForEach-Object {
            $orderedParms."$($_.Name)" = $_.Value
        }
    }

    $lgObj.properties.definition.parameters = [PsCustomObject]$orderedParms

    Out-TaskFileLogicApp -InputObject $lgObj
}

#Original file: Sort-Raw.LogicApp.Tag.task.ps1
$parm = @{
    Description = @"
Loops all LogicApp tag
Sorts tags and re-assign them to the Logic App json structure
"@
    Alias       = "Raw.Sort-Raw.LogicApp.Tag"
}

Task -Name "Sort-Raw.LogicApp.Tag" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject

    $sorted = @(foreach ($item in $lgObj.tags.PsObject.Properties) {
            switch -Wildcard ($item.Name) {
                
                default { [PsCustomObject]@{Sort = 1000; Name = $item.Name; Value = $item.Value } }
            }
        }) | Sort-Object -Property Sort

    $orderedParms = [ordered]@{}

    $groups = $sorted | Group-Object -Property Sort

    foreach ($item in $groups) {
        $item.Group | Sort-Object -Property Name | ForEach-Object {
            $orderedParms."$($_.Name)" = $_.Value
        }
    }

    $lgObj.tags = [PsCustomObject]$orderedParms

    Out-TaskFileLogicApp -InputObject $lgObj
}

