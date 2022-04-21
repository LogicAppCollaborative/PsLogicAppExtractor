$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the ResourceGroup, Namespace, AccessKey
--The type is based on ListKey / ConnectionString approach
--Name & Displayname is extracted from the ConnectionName property
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ListKey.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/servicebus*") {
            $found = $true

            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            # $pathArms = "C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor\internal\arms"

            $sbObj = Get-Content -Path "$pathArms\API.SB.ConnectionString.json" -Raw | ConvertFrom-Json

            $sbObj.Name = $_.Value.connectionName
            $sbObj.properties.displayName = $_.Value.connectionName

            $rgPreSuf = Format-Name -Type "Connection" -Prefix $Parm_Prefix -Suffix "_ResourceGroup" -Value "$($_.Name)"
            $nsPreSuf = Format-Name -Type "Connection" -Prefix $Parm_Prefix -Suffix "_Namespace" -Value "$($_.Name)"
            $keyPreSuf = Format-Name -Type "Connection" -Prefix $Parm_Prefix -Suffix "_Key" -Value "$($_.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$rgPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The resource group where the servicebus namespace is located. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The name of the servicebus namespace. ($($_.Name))"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$keyPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The name of the namespace access policy key that will be used during the deployment to fetch the connection string based on that key. ($($_.Name))"

            $sbObj.properties.parameterValues.connectionString = $sbObj.properties.parameterValues.connectionString.Replace("'##RESOURCEGROUPNAME##'", "parameters('$rgPreSuf')").Replace("'##NAMESPACE##'", "parameters('$nsPreSuf')").Replace("'##KEYNAME##'", "parameters('$keyPreSuf')")

            $armObj.resources += $sbObj
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