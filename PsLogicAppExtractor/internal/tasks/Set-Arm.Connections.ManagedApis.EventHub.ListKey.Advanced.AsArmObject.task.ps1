$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type EventHub, and that is using the classic connection string approach
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the ResourceGroup, Namespace, AccessKey
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the Api Connection Object
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.EventHub.ListKey.Advanced.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.EventHub.ListKey.Advanced.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
        
    $found = $false
    $conType = "eventhubs"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/eventhubs*" `
                -and (-not ($connectionObj.Value.id -like "*[*(*)*]*"))) {
        
            # Identity a way to identify the connection type - ConnectionString vs ManagedServiceIdentity
            # if ($connectionObj.Value.connectionProperties.authentication.type -eq "ManagedServiceIdentity") { continue }
        
            $found = $true
        
            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            
            if ($tools -eq "AzCli") {
                $resObj = az rest --url $uri | ConvertFrom-Json
            }
            else {
                $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            }

            # Use the display name as the name of the resource
            $conName = $resObj.Properties.DisplayName

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.EventHub.ListKey.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $parmApicId = Format-Name -Type "Connection" -Prefix $Prefix -Value "$($connectionObj.Name)"

            $parmApicSubscription = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Subscription" -Value "$($connectionObj.Name)"
            $parmApicResourceGroup = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ResourceGroup" -Value "$($connectionObj.Name)"
            $parmApicNamespace = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"
            $parmApicAccessKey = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_AccessKey" -Value "$($connectionObj.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicId" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
                      
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicSubscription" `
                -Type "string" `
                -Value "[subscription().subscriptionId]" `
                -Description "The subscription where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicResourceGroup" `
                -Type "string" `
                -Value "[resourceGroup().name]" `
                -Description "The resource group where the servicebus namespace is located. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicNamespace" `
                -Type "string" `
                -Value "" `
                -Description "The name of the servicebus namespace. ($($connectionObj.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicAccessKey" `
                -Type "string" `
                -Value "RootManageSharedAccessKey" `
                -Description "The name of the namespace access policy key that will be used during the deployment to fetch the connection string based on that key. ($($connectionObj.Name))"
            
            # Update the api object properties
            $apiObj.Name = "[parameters('$parmApicId')]"
            $apiObj.properties.displayName = "[parameters('$parmApicId')]"
             
            $apiObj.properties.parameterValues.connectionString = $apiObj.properties.parameterValues.connectionString.Replace("'##SUSCRIPTIONID##'", "parameters('$parmApicSubscription')").Replace("'##RESOURCEGROUPNAME##'", "parameters('$parmApicResourceGroup')").Replace("'##NAMESPACE##'", "parameters('$parmApicNamespace')").Replace("'##KEYNAME##'", "parameters('$parmApicAccessKey')")
            
            # Append the new resource to the ARM template
            $armObj.resources += $apiObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                # Create the dependsOn array if it does not exist
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }

            # Add the new resource to the dependsOn array, so that the deployment will work
            $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', parameters('$parmApicId'))]"

            # Adjust the connection object to depend on the same name
            $connectionObj.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$parmApicId'))]"
            $connectionObj.Value.connectionName = "[parameters('$parmApicId')]"
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