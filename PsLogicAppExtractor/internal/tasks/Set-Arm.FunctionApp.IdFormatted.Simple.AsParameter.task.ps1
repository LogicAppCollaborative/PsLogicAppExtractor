$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.FunctionApp.IdFormatted.Simple.AsParameter"
}

Task -Name "Set-Arm.FunctionApp.IdFormatted.Simple.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Function" }


    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.function.id -like "*``[*``]*")) {
            if ($item.Value.inputs.function.id -match "/sites/(.*)/functions/(.*)") {
                $counter += 1
                $parmName = "functionApp$($counter.ToString().PadLeft(3, "0"))"

                $functionName = $Matches[1]
                $item.Value.inputs.function.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/sites/{2}/functions/$($Matches[2])', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$functionName" `
                    -Description "The name / id of the FunctionApp that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}