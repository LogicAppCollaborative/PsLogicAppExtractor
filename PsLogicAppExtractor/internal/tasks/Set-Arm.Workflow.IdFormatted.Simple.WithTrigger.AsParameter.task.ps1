$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.Workflow.IdFormatted.Simple.WithTrigger.AsParameter"
}

Task -Name "Set-Arm.Workflow.IdFormatted.Simple.WithTrigger.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Workflow" }

    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.host.workflow.id -like "*``[*``]*")) {

            if ($item.Value.inputs.host.workflow.id -match "/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Logic/workflows/(.*)") {
                $counter += 1
                $parmName = "workFlowId$($counter.ToString().PadLeft(3, "0"))"
                $parmTrigger = "workFlowId$($counter.ToString().PadLeft(3, "0"))Trigger"

                $orgName = $Matches[1]
                $item.Value.inputs.host.workflow.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/workflows/{2}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$orgName" `
                    -Description "The name / id of the WorkFlow (LogicApp) that is referenced by the Logic App."

                $orgValue = $item.Value.inputs.host.triggerName
                $item.Value.inputs.host.triggerName = "[parameters('$parmTrigger')]"
                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmTrigger `
                    -Type "string" `
                    -Value "$orgValue" `
                    -Description "The name the method exposed by the FunctionApp that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}