$parm = @{
    Description = @"
Loops all `$connections childs
-Creates an Arm parameter, with prefix & suffix
--Sets the default value to the original name, extracted from connectionId property
-Sets the connectionId to: [resourceId('Microsoft.Web/connections', parameters('XYZ'))]
-Sets the connectionName to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AsParameter"
}

Task -Name "Set-Arm.Connections.ManagedApis.AsParameter" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $namePreSuf = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value $_.Name
            
            $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
                -Type "string" `
                -Value $conName `
                -Description "The name / id of the ManagedApi connection object that is being utilized by the Logic App. Will be for the trigger and other actions that depend on connections."
    
            $_.Value.connectionId = "[resourceId('Microsoft.Web/connections', parameters('$namePreSuf'))]"
            $_.Value.connectionName = "[parameters('$namePreSuf')]"
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}