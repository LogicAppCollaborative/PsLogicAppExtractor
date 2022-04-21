$parm = @{
    Description = @"
Loops all `$connections children
-Sets connectionId to the name of the connection, extracted from the connectionName
"@
    Alias       = "Raw.Set-Raw.Connections.ManagedApis.Id"
}

Task -Name "Set-Raw.Connections.ManagedApis.Id" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {
            $conName = $_.Value.connectionId.Split("/") | Select-Object -Last 1
            $_.Value.connectionId = $_.Value.connectionId.Replace($conName, $_.Value.connectionName)
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}