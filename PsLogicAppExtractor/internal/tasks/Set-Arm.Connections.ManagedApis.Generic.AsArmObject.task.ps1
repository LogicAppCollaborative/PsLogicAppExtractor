$parm = @{
    Description = @"
Loops all `$connections children
-Validates that is of the type ManagedApi
--Creates a new resource in the ARM template, for the ApiConnection object
--Makes sure the ARM Parameters logicAppLocation exists
--Name & Displayname is extracted from the ConnectionName property
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.Generic.AsArmObject"
}

Task -Name "Set-Arm.Connections.ManagedApis.Generic.AsArmObject" @parm -Action {
    Set-TaskWorkDirectory

    $found = $false

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {

        if ($_.Value.id -match "/managedApis/(.*)") {
            $found = $true
            
            $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"

            $conObj = Get-Content -Path "$pathArms\API.Managed.json" -Raw | ConvertFrom-Json

            $conObj.Name = $_.Value.connectionName
            $conObj.properties.displayName = $_.Value.connectionName
            $conObj.properties.api.id = $conObj.properties.api.id.Replace("##TYPE##", $Matches[1])
            $armObj.resources += $conObj

            if ($null -eq $armObj.resources[0].dependsOn) {
                $armObj.resources[0] | Add-Member -MemberType NoteProperty -Name "dependsOn" -Value @()
            }

            if ($($_.Value.connectionName) -match "\[(.*)\]") {
                $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', $($Matches[1]))]"
            }
            else {
                $armObj.resources[0].dependsOn += "[resourceId('Microsoft.Web/connections', '$($_.Value.connectionName)')]"
            }
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