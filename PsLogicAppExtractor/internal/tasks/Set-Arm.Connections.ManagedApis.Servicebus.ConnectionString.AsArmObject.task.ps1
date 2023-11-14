$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus, and that is using the classic connection string approach
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the connection string as a Secure String
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ConnectionString approach
--Displayname is extracted from the Api Connection Object
--The displayname will be configured to be the same as the name of the connection
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ConnectionString.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ConnectionString.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
        
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
            $apiObj = Get-Content -Path "$pathArms\API.SB.ConnectionString.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $conStrPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ConnectionString" -Value "$($connectionObj.Name)"

            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$conStrPreSuf" `
                -Type "SecureString" `
                -Value "" `
                -Description "The complete connection string for the namespace. ($($connectionObj.Name))"

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"
            $apiObj.properties.parameterValues.connectionString = $apiObj.properties.parameterValues.connectionString.Replace("##CONNECTIONSTRING##", "$conStrPreSuf")
            
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