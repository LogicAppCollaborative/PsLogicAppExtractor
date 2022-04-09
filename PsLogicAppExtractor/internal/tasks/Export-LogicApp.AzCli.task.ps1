$parm = @{
    Description = "Exports the raw version of the Logic App from the Azure Portal"
    Alias       = "Exporter.Export-LogicApp.AzCli"
}

Task -Name "Export-LogicApp.AzCli" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath
    
    if ($SubscriptionId -and $ResourceGroup) {
        $lg = az rest --url "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Logic/workflows/$Name" --url-parameters api-version=2019-05-01
    }
    else {
        $id = az resource show --resource-group $ResourceGroup --resource-type "Microsoft.Logic/workflows" --Name $Name --query "id" | ConvertFrom-Json
        $lg = az rest --url "$id" --url-parameters api-version=2019-05-01
    }
    
    if ($null -eq $lg) {
        #TODO! We need to throw an error
        Throw
    }
    
    $res = $lg -join ""
    Out-TaskFile -Path "$filePath\$Name.json" -Content $res
}