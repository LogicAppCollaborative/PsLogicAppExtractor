$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type EventHub, and is using the Managed Identity authentication scheme
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Namespace
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on the Managed Identity authentication
--Name & Displayname is extracted from the ConnectionName property
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Eventhub.ManagedIdentity.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Eventhub.ManagedIdentity.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory
    
    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
        
    $found = $false
    $conType = "servicebus"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/eventhubs*") {

            # This should only handle Managed Identity Eventhub connections
            if ($connectionObj.Value.connectionProperties.authentication.type -ne "ManagedServiceIdentity") { continue }

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
            $resName = $resObj.Properties.DisplayName

            if ($resObj.Properties.parameterValueSet.values.namespaceEndpoint.value -match "sb://(.*).servicebus.windows.net") {
                $resName = $Matches[1]
            }

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Eventhub.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $parmApicId = Format-Name -Type "Connection" -Prefix $Prefix -Value "$($connectionObj.Name)"
            $parmApicNamespace = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicId" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicNamespace" `
                -Type "string" `
                -Value "$resName" `
                -Description "The name of the eventhub namespace. ($($connectionObj.Name))"

            # Update the api object properties
            $apiObj.Name = "[parameters('$parmApicId')]"
            $apiObj.properties.displayName = "[parameters('$parmApicId')]"
            $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value = $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value.Replace("'##NAMESPACE##'", "parameters('$parmApicNamespace')")

            # $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            # $nsPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Namespace" -Value "$($connectionObj.Name)"

            # $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
            #     -Type "string" `
            #     -Value "$resName" `
            #     -Description "The name of the servicebus namespace. ($($connectionObj.Name))"

            # $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
            #     -Type "string" `
            #     -Value $conName `
            #     -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            # # Update the api object properties
            # $apiObj.Name = "[parameters('$idPreSuf')]"
            # $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            # $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value = $apiObj.properties.parameterValueSet.values.namespaceEndpoint.value.Replace("'##NAMESPACE##'", "parameters('$nsPreSuf')")

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