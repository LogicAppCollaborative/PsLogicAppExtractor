$parm = @{
    Description = @"
Loops all `$connections childs
-Sets the id value to: [format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/XYZ',subscription().subscriptionId,parameters('logicAppLocation'))]
Creates the Arm parameter logicAppLocation if it doesn't exists
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.IdFormatted"
}

Task -Name "Set-Arm.Connections.ManagedApis.IdFormatted" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath
    
    $found = $false

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $found = $true
            $conType = $_.Value.id.Split("/") | Select-Object -Last 1
            $_.Value.id = "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/$conType',subscription().subscriptionId,parameters('logicAppLocation'))]"
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

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}