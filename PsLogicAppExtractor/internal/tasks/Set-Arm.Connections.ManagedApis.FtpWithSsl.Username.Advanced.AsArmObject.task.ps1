$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type ftp
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Hostname, Username, Password
--Makes sure the ARM Parameters logicAppLocation exists
--Name & Displayname is extracted from the Api Connection Object
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.FtpWithSsl.Username.Advanced.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.FtpWithSsl.Username.Advanced.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools

    $found = $false
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/ftp*") {
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
            $hostName = $resObj.Properties.ParameterValues.serverAddress
            $userName = $resObj.Properties.ParameterValues.userName
            $portNumber = $resObj.Properties.ParameterValues.serverPort
            $sslEnabled = $resObj.Properties.ParameterValues.isSSL
            $disableCertVali = $resObj.Properties.ParameterValues.disableCertificateValidation
            $binary = $resObj.Properties.ParameterValues.isBinaryTransport
            $closeCon = $resObj.Properties.ParameterValues.closeConnectionAfterRequestCompletion
            

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.FtpWithSsl.Username.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $hostPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Hostname" -Value "$($_.Name)"
            $userPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Username" -Value "$($_.Name)"
            $passPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Password" -Value "$($_.Name)"
            $portPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Portnumber" -Value "$($_.Name)"
            $sslPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_SslEnabled" -Value "$($_.Name)"
            $disableCertValiPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisableCertificateValidation" -Value "$($_.Name)"
            $binaryPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_BinaryTransport" -Value "$($_.Name)"
            $closePreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_CloseConnectionAfterRequest" -Value "$($_.Name)"
            
            $idPreSuf = Format-Name -Type "Connection" -Value "$($_.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($_.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$hostPreSuf" `
                -Type "string" `
                -Value "$hostName" `
                -Description "The host / server address for the ftp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$userPreSuf" `
                -Type "string" `
                -Value "$userName" `
                -Description "The username used to authenticate against the ftp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$passPreSuf" `
                -Type "SecureString" `
                -Value "" `
                -Description "The password used to authenticate against the ftp server. ($($_.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$portPreSuf" `
                -Type "string" `
                -Value "$portNumber" `
                -Description "The port used to communicate with the ftp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$sslPreSuf" `
                -Type "bool" `
                -Value $sslEnabled `
                -Description "True will make sure to use SSL connection against ftp server. ($($_.Name))"
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$disableCertValiPreSuf" `
                -Type "bool" `
                -Value $disableCertVali `
                -Description "True will accept any certificate presented from the ftp server. ($($_.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$binaryPreSuf" `
                -Type "bool" `
                -Value $binary `
                -Description "True will force communication with the ftp server to be binary based. ($($_.Name))"
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$closePreSuf" `
                -Type "bool" `
                -Value $closeCon `
                -Description "True will close/terminate the connection with the ftp server when a command is completed. ($($_.Name))"
                
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
            $apiObj.Properties.ParameterValues.serverPort = "[parameters('$portPreSuf')]"
            $apiObj.Properties.ParameterValues.isSSL = "[parameters('$sslPreSuf')]"
            $apiObj.Properties.ParameterValues.disableCertificateValidation = "[parameters('$disableCertValiPreSuf')]"
            $apiObj.Properties.ParameterValues.isBinaryTransport = "[parameters('$binaryPreSuf')]"
            $apiObj.Properties.ParameterValues.closeConnectionAfterRequestCompletion = "[parameters('$closePreSuf')]"

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