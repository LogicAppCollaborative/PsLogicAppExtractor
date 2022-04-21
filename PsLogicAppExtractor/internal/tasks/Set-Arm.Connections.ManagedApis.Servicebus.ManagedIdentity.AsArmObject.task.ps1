$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type servicebus
--Creates a new resource in the ARM template, for the ApiConnection object
--With matching ARM Parameters, for the Namespace
--The type is based on the Managed Identity authentication
--Name & Displayname is extracted from the ConnectionName property
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory
    
    $found = $false

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -like "*managedApis/servicebus*") {
            $found = $true

            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
            # $pathArms = "C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor\internal\arms"

            $sbObj = Get-Content -Path "$pathArms\API.SB.Managed.json" -Raw | ConvertFrom-Json

            $sbObj.Name = $_.Value.connectionName
            $sbObj.properties.displayName = $_.Value.connectionName

            $nsPreSuf = Format-Name -Type "Connection" -Prefix $Parm_Prefix -Suffix "_Namespace" -Value "$($_.Name)"

            $armObj = Add-ArmParameter -InputObject $armObj -Name "$nsPreSuf" `
                -Type "string" `
                -Value "" `
                -Description "The name of the servicebus namespace. ($($_.Name))"

            $sbObj.properties.parameterValueSet.values.namespaceEndpoint.value = $sbObj.properties.parameterValueSet.values.namespaceEndpoint.value.Replace("'##NAMESPACE##'", "parameters('$nsPreSuf')")

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