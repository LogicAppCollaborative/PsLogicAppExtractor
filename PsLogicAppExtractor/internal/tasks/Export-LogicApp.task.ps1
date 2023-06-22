$parm = @{
    Description = "Exports the raw version of the Logic App from the Azure Portal"
    Alias       = "Exporter.Export-LogicApp"
}

Task -Name "Export-LogicApp" @parm -Action {
    Set-TaskWorkDirectory
    
    # We can either use the az cli or the Az modules
    $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools


    if ($SubscriptionId -and $ResourceGroup) {
        $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Logic/workflows/$Name`?api-version=2019-05-01"
        
        # Write-Host "Direct URL '$($uri)'"

        if ($tools -eq "AzCli") {
            $resObj = az rest --url $uri | ConvertFrom-Json
        }
        else {
            $resObj = Invoke-AzRestMethod -Uri $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
        }
    }
    else {
        # Write-Host "Searching for the Logic App"

        if ($tools -eq "AzCli") {
            $id = az resource show --resource-group $ResourceGroup --resource-type "Microsoft.Logic/workflows" --name $Name --query "id" | ConvertFrom-Json
            $resObj = az rest --url "$id" --url-parameters api-version=2019-05-01 | ConvertFrom-Json
        }
        else {
            
            $resObj = Invoke-AzRestMethod -Method Get -ResourceGroupName $ResourceGroup -ResourceProviderName 'Microsoft.Logic' -ResourceType 'workflows' -Name $Name -ApiVersion "2019-05-01" | Select-Object -ExpandProperty content | ConvertFrom-Json
        }
    }
    
    if ($null -eq $resObj) {
        #TODO! We need to throw an error
        Throw
    }
    
    Out-TaskFile -InputObject $resObj
}