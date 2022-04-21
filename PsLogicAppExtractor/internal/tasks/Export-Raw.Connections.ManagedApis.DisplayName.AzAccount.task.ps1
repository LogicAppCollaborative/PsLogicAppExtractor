$parm = @{
    Description = @"
Loops all `$connections childs
-Exports the DisplayName of the ManagedApis based on the ConnectionId / ResourceId
--Sets connectionName to the DisplayName, extracted via the ConnectionId
Requires an authenticated Az.Accounts session
"@
    Alias       = "Exporter.Export-Raw.Connections.ManagedApis.DisplayName.AzAccount"
}

Task -Name "Export-Raw.Connections.ManagedApis.DisplayName.AzAccount" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    $lgObj.properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {

            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)

            $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json

            $conName = $resObj.Properties.DisplayName
            $_.Value.connectionName = $conName
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}