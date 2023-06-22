$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Dataverse.ServicePrincipal.Advanced.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Dataverse.ServicePrincipal.Advanced.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools

    $found = $false
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/commondataservice*") {
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
            $tenantId = $resObj.Properties.ParameterValues."token:TenantId"
            $clientId = $resObj.Properties.ParameterValues."token:clientId"
            
            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Dataverse.ServicePrincipal.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $tenantPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_TenantId" -Value "$($_.Name)"
            $clientPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ClientId" -Value "$($_.Name)"
            $secretPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_ClientSecret" -Value "$($_.Name)"
            
            $idPreSuf = Format-Name -Type "Connection" -Value "$($_.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($_.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$tenantPreSuf" `
                -Type "string" `
                -Value "$tenantId" `
                -Description "The Azure tenant id that the Dataverse instance is connected to. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$clientPreSuf" `
                -Type "string" `
                -Value "$clientId" `
                -Description "The ClientId used to authenticate against the Dataverse instance. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$secretPreSuf" `
                -Type "SecureString" `
                -Value "" `
                -Description "The ClientSecret used to authenticate against the Dataverse instance. ($($_.Name))"
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The id/name of the ManagedApi connection object that is being utilized by the Logic App."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$displayPreSuf" `
                -Type "string" `
                -Value $displayName `
                -Description "The display name of the ManagedApi connection object that is being utilized by the Logic App."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$displayPreSuf')]"
            $apiObj.Properties.ParameterValues."token:TenantId" = "[parameters('$tenantPreSuf')]"
            $apiObj.Properties.ParameterValues."token:clientId" = "[parameters('$clientPreSuf')]"
            $apiObj.Properties.ParameterValues."token:clientSecret" = "[parameters('$secretPreSuf')]"

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