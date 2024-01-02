$parm = @{
  Description = @"
Loops all diagnosticSettings children for the Logic App
-Validates that is of the type Log Analytics (Workspace)
--Creates a new resource in the ARM template, for the diagnosticSettings object
--With matching ARM Parameters, for the WorkspaceId, WorkspaceResourceGroup, Name
--WorkspaceId, WorkspaceResourceGroup & Name is extracted from the DiagnosticSettings Object
Requires an authenticated session, either Az.Accounts or az cli
"@
  Alias       = "Arm.Set-Arm.Diagnostics.Settings.Workspace.Advanced.AsArmObject"
}

Task -Name "Set-Arm.Diagnostics.Settings.Workspace.Advanced.AsArmObject" @parm -Action {
  Set-TaskWorkDirectory

  # We can either use the az cli or the Az modules
  $tools = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.Tools
  $pathArms = "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Base)\internal\arms"

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

  if ($null -eq $diagSettings -or $diagSettings.Count -eq 0) {
    $diagFake = Get-Content -Path "$pathArms\DIAG.Workspace.Simple.json" -Raw | ConvertFrom-Json
    $diagSettings = @($diagFake)
  }

  $counter = 0

  foreach ($diag in $diagSettings) {
    if ([System.String]::IsNullOrEmpty($diag.properties.workspaceId)) {
      continue
    }
    
    $orgName = $diag.name
    $orgResourceGroup = ($diag.properties.workspaceId | Select-String -Pattern ".*/resourceGroups/(.*?)/providers/").Matches[0].Groups[1].Value
    $orgWorkspace = $diag.properties.workspaceId.Split("/") | Select-Object -Last 1

    $counter += 1

    $parmName = "diagnostic$($counter.ToString().PadLeft(3, "0"))_Name"
    $parmWorkspace = "diagnostic$($counter.ToString().PadLeft(3, "0"))_WorkspaceId"
    $parmRgWorkspace = "diagnostic$($counter.ToString().PadLeft(3, "0"))_ResourceGroup"

    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
      -Type "string" `
      -Value "$orgName" `
      -Description "The name of diagnostic setting / profile for the Logic App."

    $armObj = Add-ArmParameter -InputObject $armObj -Name "$parmRgWorkspace" `
      -Type "string" `
      -Value "$orgResourceGroup" `
      -Description "The resource group where the Log Analytics (Workspace) is located."
                
    $armObj = Add-ArmParameter -InputObject $armObj -Name $parmWorkspace `
      -Type "string" `
      -Value "$orgWorkspace" `
      -Description "The name / id of the Log Analytics (Workspace) that is referenced by the Logic App and its diagnostic settings."
      
    # Fetch base template
    
    $diagObj = Get-Content -Path "$pathArms\DIAG.Workspace.Simple.json" -Raw | ConvertFrom-Json
    
    $diagObj.Name = "[format('{0}/Microsoft.Insights/{1}', parameters('logicAppName'), parameters('$parmName'))]"
    $diagObj.Type = "Microsoft.Logic/workflows/providers/diagnosticSettings"
    $diagObj.properties.workspaceId = "[resourceId(parameters('$parmRgWorkspace'), 'Microsoft.OperationalInsights/workspaces', parameters('$parmWorkspace'))]"
    $diagObj.properties.logs = $diag.properties.logs
    $diagObj.properties.metrics = $diag.properties.metrics
    
    $diagObj.psobject.Properties.Remove("scope")
    
    $armObj.resources += $diagObj
  }

  Out-TaskFileArm -InputObject $armObj
}