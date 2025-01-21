$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type SQL and is using the Managed Identity authentication scheme
--Creates a new resource in the ARM template, for the ApiConnection object
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on the Managed Identity authentication
--Name & Displayname is extracted from the ConnectionName property
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AzureSql.ManagedIdentity.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.AzureSql.ManagedIdentity.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory
    
    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
        
    $found = $false
    $conType = "sql"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/sql*") {

            # This should only handle Managed Identity Servicebus connections
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
            $resName = $resObj.Properties.DisplayName #fallback default value

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Sql.Managed.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $idPreSuf = Format-Name -Type "Connection" -Value "$($connectionObj.Name)"

            <#! Needs work if we want to extract it from the first action that uses the connection
            # $nsPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Server" -Value "$($connectionObj.Name)"
            # $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
            #     -Type "string" `
            #     -Value "$resName" `
            #     -Description "The name/address of the Azure SQL Server (instance). ($($connectionObj.Name))"
            #>

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$idPreSuf')]"

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