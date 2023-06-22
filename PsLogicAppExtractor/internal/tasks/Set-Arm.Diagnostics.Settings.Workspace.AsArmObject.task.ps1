$parm = @{
  Description = @"
Requires an authenticated session, either Az.Accounts or az cli
"@
  Alias       = "Arm.Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzAccount"
}

Task -Name "Set-Arm.Diagnostics.Settings.Workspace.AsArmObject.AzAccount" @parm -Action {
  Set-TaskWorkDirectory

  # We can either use the az cli or the Az modules
  $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
      
  $armObj = Get-TaskWorkObject

  $subLocal = (Get-AzContext).Subscription.Id

  if ($SubscriptionId) {
    $subLocal = $SubscriptionId
  }
   
  $uri = "/subscriptions/$subLocal/resourceGroups/$ResourceGroup/providers/Microsoft.Logic/workflows/$Name/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview"

  if ($tools -eq "AzCli") {
    $resObj = az rest --url $uri | ConvertFrom-Json
  }
  else {
    $resObj = Invoke-AzRestMethod -Path $uri -Method Get | Select-Object -ExpandProperty content | ConvertFrom-Json
  }

  $diagSettings = @($resObj | Select-Object -ExpandProperty Value)

  $counter = 0

  foreach ($diag in $diagSettings) {
    if ([System.String]::IsNullOrEmpty($diag.properties.workspaceId)) {
      continue
    }

    $orgName = $diag.name
    $orgWorkspace = $diag.properties.workspaceId.Split("/") | Select-Object -Last 1

    $counter += 1

    $parmName = "diagnostic$($counter.ToString().PadLeft(3, "0"))_Name"
    $parmWorkspace = "diagnostic$($counter.ToString().PadLeft(3, "0"))_WorkspaceId"

    $diag.properties.workspaceId = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OperationalInsights/workspaces/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"
        
    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
      -Type "string" `
      -Value "$orgName" `
      -Description "The name of diagnostic setting / profile for the Logic App."

    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmWorkspace `
      -Type "string" `
      -Value "$orgWorkspace" `
      -Description "The name / id of the Log Analytics (Workspace) that is referenced by the Logic App and its diagnostic settings."
      
    # Fetch base template
    $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"
    $diagObj = Get-Content -Path "$pathArms\DIAG.Workspace.Simple.json" -Raw | ConvertFrom-Json
    
    $diagObj.Name = "[parameters('$parmName')]"
    $diagObj.properties.workspaceId = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OperationalInsights/workspaces/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmWorkspace'))]"
    $diagObj.properties.logs = $diag.properties.logs
    $diagObj.properties.metrics = $diag.properties.metrics
    $armObj.resources += $diagObj

  }

  Out-TaskFileArm -InputObject $armObj
}