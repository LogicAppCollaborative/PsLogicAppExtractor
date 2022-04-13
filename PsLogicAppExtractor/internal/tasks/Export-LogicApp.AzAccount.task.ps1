$parm = @{
    Description = "Exports the raw version of the Logic App from the Azure Portal"
    Alias       = "Exporter.Export-LogicApp.AzAccount"
}

Task -Name "Export-LogicApp.AzAccount" @parm -Action {
    Set-TaskWorkDirectory
    
    $params = @{
        ResourceGroupName    = "$ResourceGroup"
        ResourceProviderName = 'Microsoft.Logic'
        ResourceType         = 'workflows'
        Name                 = "$Name"
        ApiVersion           = "2019-05-01"
        Method               = 'GET'
    }

    if ($SubscriptionId) {
        $params.SubscriptionId = "$SubscriptionId"
    }

    $lg = Invoke-AzRestMethod @params
    
    if ($null -eq $lg) {
        #TODO! We need to throw an error
        Throw
    }
    
    $res = $lg.Content
    Out-TaskFile -Content $res
}