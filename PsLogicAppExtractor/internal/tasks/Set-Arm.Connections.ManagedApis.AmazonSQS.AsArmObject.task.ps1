$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type AmazonSQS
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the 'Access Key Secret' as a Secure String
--Makes sure the ARM Parameters logicAppLocation exists
--Displayname is extracted from the Api Connection Object
--The displayname will be configured to be the same as the name of the connection
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AmazonSQS.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.AmazonSQS.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
        
    $found = $false
    $conType = "amazonsqs"

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -like "*managedApis/amazonsqs*"`
                -and (-not ($connectionObj.Value.id -like "*[*(*)*]*"))) {
            
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
            $apiObj = Get-Content -Path "$pathArms\API.Amazon.SQS.json" -Raw | ConvertFrom-Json
            
            # Set the names of the parameters
            $Prefix = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
            $parmApicId = Format-Name -Type "Connection" -Prefix $Prefix -Value "$($connectionObj.Name)"

            $parmApicQueueUrl = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_QueueUrl" -Value "$($connectionObj.Name)"
            $parmApicAccessKeyId = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_AccessKeyId" -Value "$($connectionObj.Name)"
            $parmApicSecretAccessKey = Format-Name -Type "Connection" -Prefix $Prefix -Suffix "_SecretAccessKey" -Value "$($connectionObj.Name)"
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicId" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicQueueUrl" `
                -Type "string" `
                -Value "$($resObj.Properties.parameterValues.queueUrl)" `
                -Description "The Url for the SQS as provided from Amazon."
                
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicAccessKeyId" `
                -Type "string" `
                -Value "$($resObj.Properties.parameterValues.accessKeyId)" `
                -Description "The Access Key as provided from Amazon."

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmApicSecretAccessKey" `
                -Type "SecureString" `
                -Value "" `
                -Description "The Secret Access Key as provided from Amazon."

            # Update the api object properties
            $apiObj.Name = "[parameters('$parmApicId')]"
            $apiObj.properties.displayName = "[parameters('$parmApicId')]"
            
            $apiObj.properties.parameterValues.queueUrl = "[parameters('$parmApicQueueUrl')]"
            $apiObj.properties.parameterValues.accessKeyId = "[parameters('$parmApicAccessKeyId')]"
            $apiObj.properties.parameterValues.secretAccessKey = "[parameters('$parmApicSecretAccessKey')]"

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