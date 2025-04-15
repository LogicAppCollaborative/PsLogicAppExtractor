$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type smtp
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Hostname, Username, Password, Port, Ssl
--Makes sure the ARM Parameters logicAppLocation exists
--Name & Displayname is extracted from the Api Connection Object
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Smtp.Username.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Smtp.Username.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools

    $found = $false
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/smtp*") {
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
            $conName = $resObj.Properties.DisplayName
            $displayName = $resObj.Properties.DisplayName
            $hostName = $resObj.Properties.ParameterValues.serverAddress
            $userName = $resObj.Properties.ParameterValues.userName
            $portNumber = $resObj.Properties.ParameterValues.port
            $enableSsl = $resObj.Properties.ParameterValues.enableSSL

            if ([string]::IsNullOrEmpty($portNumber)) {
                $portNumber = 587
            }

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Smtp.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $hostPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Hostname" -Value "$($_.Name)"
            $userPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Username" -Value "$($_.Name)"
            $passPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Password" -Value "$($_.Name)"
            $portPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Port" -Value "$($_.Name)"
            $sslPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_EnableSsl" -Value "$($_.Name)"
            
            $idPreSuf = Format-Name -Type "Connection" -Value "$($_.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($_.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$hostPreSuf" `
                -Type "string" `
                -Value "$hostName" `
                -Description "The host / server address for the Smtp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$userPreSuf" `
                -Type "string" `
                -Value "$userName" `
                -Description "The username used to authenticate against the Smtp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$passPreSuf" `
                -Type "SecureString" `
                -Value "" `
                -Description "The password used to authenticate against the Smtp server. ($($_.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$portPreSuf" `
                -Type "string" `
                -Value "$portNumber" `
                -Description "The port used to communicate with the Smtp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$sslPreSuf" `
                -Type "bool" `
                -Value $enableSsl `
                -Description "Indicate if you need SSL turned on to authenticate against the Smtp server. ($($_.Name))"
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$displayPreSuf" `
                -Type "string" `
                -Value $displayName `
                -Description "The display name of the ManagedApi connection object that is being utilized by the Logic App."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$idPreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
                
            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$displayPreSuf')]"
            $apiObj.Properties.ParameterValues.serverAddress = "[parameters('$hostPreSuf')]"
            $apiObj.Properties.ParameterValues.userName = "[parameters('$userPreSuf')]"
            $apiObj.Properties.ParameterValues.password = "[parameters('$passPreSuf')]"
            $apiObj.Properties.ParameterValues.port = "[parameters('$portPreSuf')]"
            $apiObj.Properties.ParameterValues.enableSSL = "[parameters('$sslPreSuf')]"

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