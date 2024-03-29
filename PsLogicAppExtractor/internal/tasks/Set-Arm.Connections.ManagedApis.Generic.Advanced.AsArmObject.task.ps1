﻿$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type ManagedApi
--Creates a new resource in the ARM template, for the ApiConnection object
--Makes sure the ARM Parameters logicAppLocation exists
--Name & Displayname is extracted from the Api Connection Object
--Extends the dependsOn property on the LogicApp resource, to depend on the ApiConnection object
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Generic.Advanced.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Generic.Advanced.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory
    
    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools

    $found = $false

    $armObj = Get-TaskWorkObject

    foreach ($connectionObj in $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties) {
        if ($connectionObj.Value.id -match "/managedApis/(.*)") {
            
            # We have specialized templates for these types
            if ($Matches[1] -in @("azureblob", "azurefile", "azuretables", "servicebus")) { continue }

            $found = $true
            $conType = $Matches[1]

            # Fetch the details from the connection object
            $uri = "{0}?api-version=2018-07-01-preview" -f $($connectionObj.Value.connectionId)
            
            if ($tools -eq "AzCli") {
                $resObj = az rest --url $uri | ConvertFrom-Json
            }
            else {
                $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            }
            
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