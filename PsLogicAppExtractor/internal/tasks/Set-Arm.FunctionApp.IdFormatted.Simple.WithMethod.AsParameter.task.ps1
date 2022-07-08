$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.FunctionApp.IdFormatted.Simple.WithMethod.AsParameter"
}

Task -Name "Set-Arm.FunctionApp.IdFormatted.Simple.WithMethod.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Function" }


    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.function.id -like "*``[*``]*")) {
            if ($item.Value.inputs.function.id -match "/sites/(.*)/functions/(.*)") {
                $counter += 1
                $parmName = "functionApp$($counter.ToString().PadLeft(3, "0"))"
                $parmMethod = "functionApp$($counter.ToString().PadLeft(3, "0"))Method"

                $functionName = $Matches[1]
                $functionMethod = $Matches[2]

                $item.Value.inputs.function.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/sites/{2}/functions/{3}}', subscription().subscriptionId, resourceGroup().name, parameters('$parmName'), parameters('$parmMethod'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$functionName" `
                    -Description "The name / id of the FunctionApp that is referenced by the Logic App."

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmMethod `
                    -Type "string" `
                    -Value "$functionMethod" `
                    -Description "The name the method exposed by the FunctionApp that is referenced by the Logic App."
                    
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}