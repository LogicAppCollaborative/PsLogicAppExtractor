$parm = @{
    Description = @"
Loops all `$connections childs
-Creates an Arm variable, with prefix & suffix
--Sets the value to the original name, extracted from connectionId property
-Sets the connectionId to: [resourceId('Microsoft.Web/connections', variables('XYZ'))]
-Sets the connectionName to: [variables('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Connections.ManagedApis.AsVariable"
}

Task -Name "Set-Arm.Connections.ManagedApis.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $namePreSuf = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value $_.Name
            
            $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $conName
    
            $_.Value.connectionId = "[resourceId('Microsoft.Web/connections', variables('$namePreSuf'))]"
            $_.Value.connectionName = "[variables('$namePreSuf')]"
        }
    }

    Out-TaskFileArm -InputObject $armObj
}