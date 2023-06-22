$parm = @{
    Description = @"
Loops all `$connections children
-Exports the DisplayName of the ManagedApis based on the ConnectionId / ResourceId
--Sets connectionName to the DisplayName, extracted via the ConnectionId
Requires an authenticated session, either Az.Accounts or az cli
"@
    Alias       = "Exporter.Export-Raw.Connections.ManagedApis.DisplayName"
}

Task -Name "Export-Raw.Connections.ManagedApis.DisplayName" @parm -Action {
    Set-TaskWorkDirectory
    
    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
        
    $lgObj = Get-TaskWorkObject
    $lgObj.properties.parameters.'$connections'.value.PsObject.Properties | ForEach-Object {
        if ($_.Value.id -like "*managedApis*") {

            $uri = "{0}?api-version=2018-07-01-preview" -f $($_.Value.connectionId)

            if ($tools -eq "AzCli") {
                $resObj = az rest --url $uri | ConvertFrom-Json
            }
            else {
                $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
            }

            $conName = $resObj.Properties.DisplayName
            $_.Value.connectionName = $conName
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}