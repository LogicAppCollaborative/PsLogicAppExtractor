$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type azuretable
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the SubscriptionId, ResourceGroup, Namespace, Key
--Makes sure the ARM Parameters logicAppLocation exists
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the Api Connection Object
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.SftpWithSsh.Username.Advanced.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.SftpWithSsh.Username.Advanced.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools

    $found = $false
    
    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/sftpwithssh*") {
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
            $hostName = $resObj.Properties.ParameterValues.hostName
            $userName = $resObj.Properties.ParameterValues.userName
            $portNumber = $resObj.Properties.ParameterValues.portNumber
            $rootFolder = $resObj.Properties.ParameterValues.rootFolder
            $accept = $resObj.Properties.ParameterValues.acceptAnySshHostKey
            $fingerprint = $resObj.Properties.ParameterValues.sshHostKeyFingerprint
            

            # Fetch base template
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            $apiObj = Get-Content -Path "$pathArms\API.Storage.Table.AccessKey.json" -Raw | ConvertFrom-Json

            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $hostPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Hostname" -Value "$($_.Name)"
            $userPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Username" -Value "$($_.Name)"
            $passPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Password" -Value "$($_.Name)"
            $portPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Portnumber" -Value "$($_.Name)"
            $rootPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_Rootfolder" -Value "$($_.Name)"
            $acceptPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_AcceptAnySshHostkey" -Value "$($_.Name)"
            $fingerPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_SshHostKeyFingerprint" -Value "$($_.Name)"
            
            $idPreSuf = Format-Name -Type "Connection" -Value "$($_.Name)"
            $displayPreSuf = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_DisplayName" -Value "$($_.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$hostPreSuf" `
                -Type "string" `
                -Value "$hostName" `
                -Description "The host / server address for the Sftp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$userPreSuf" `
                -Type "string" `
                -Value "$userName" `
                -Description "The username used to authenticate against the Sftp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$passPreSuf" `
                -Type "SecureString" `
                -Value "" `
                -Description "The password used to authenticate against the Sftp server. ($($_.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$portPreSuf" `
                -Type "string" `
                -Value "$portNumber" `
                -Description "The port used to communicate with the Sftp server. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$rootPreSuf" `
                -Type "string" `
                -Value "$rootFolder" `
                -Description "The root folder path on the Sftp server. ($($_.Name))"
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$acceptPreSuf" `
                -Type "boolean" `
                -Value $accept `
                -Description "True will accept any Ssh Host Keys presented from the Sftp server. ($($_.Name))"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$fingerPreSuf" `
                -Type "string" `
                -Value "$fingerprint" `
                -Description "The fingerprint that you expect during the initial communication with the Sftp server. ($($_.Name))"
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$displayPreSuf" `
                -Type "string" `
                -Value $displayName `
                -Description "The display name of the ManagedApi connection object that is being utilized by the Logic App."

            # Update the api object properties
            $apiObj.Name = "[parameters('$idPreSuf')]"
            $apiObj.properties.displayName = "[parameters('$displayPreSuf')]"
            $resObj.Properties.ParameterValues.hostName = "[parameters('$hostPreSuf')]"
            $resObj.Properties.ParameterValues.userName = "[parameters('$userPreSuf')]"
            $resObj.Properties.ParameterValues.password = "[parameters('$passPreSuf')]"
            $resObj.Properties.ParameterValues.portNumber = "[parameters('$portPreSuf')]"
            $resObj.Properties.ParameterValues.rootFolder = "[parameters('$rootPreSuf')]"
            $resObj.Properties.ParameterValues.acceptAnySshHostKey = "[parameters('$acceptPreSuf')]"
            $resObj.Properties.ParameterValues.sshHostKeyFingerprint = "[parameters('$fingerPreSuf')]"

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