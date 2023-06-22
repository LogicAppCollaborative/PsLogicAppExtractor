﻿$parm = @{
    Description = @"
"@
    Alias       = "Arm.Set-Arm.FunctionApp.IdFormatted.Advanced.WithMethod.AsParameter"
}

Task -Name "Set-Arm.FunctionApp.IdFormatted.Advanced.WithMethod.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $counter = 0
    $actions = $armObj.resources[0].properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Function" }

    foreach ($item in $actions) {
        if (-not ($item.Value.inputs.function.id -like "*``[*``]*")) {
            if ($item.Value.inputs.function.id -match "/subscriptions/.*/resourceGroups/(.*)/providers/Microsoft.Web/sites/(.*)/functions/(.*)") {
                $counter += 1
                $parmName = "functionApp$($counter.ToString().PadLeft(3, "0"))"
                $parmGroup = "functionApp$($counter.ToString().PadLeft(3, "0"))ResourceGroup"
                $parmMethod = "functionApp$($counter.ToString().PadLeft(3, "0"))Method"

                $functionGroup = $Matches[1]
                $functionName = $Matches[2]
                $functionMethod = $Matches[3]

                $item.Value.inputs.function.id = "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/sites/{2}/functions/{3})', subscription().subscriptionId, parameters('$parmGroup'), parameters('$parmName'), parameters('$parmMethod'))]"

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmName `
                    -Type "string" `
                    -Value "$functionName" `
                    -Description "The name / id of the FunctionApp that is referenced by the Logic App."

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmGroup `
                    -Type "string" `
                    -Value $functionGroup `
                    -Description "The resource group where the FunctionApp that is referenced by the Logic App."

                $armObj = Add-ArmParameter -InputObject $armObj -Name $parmMethod `
                    -Type "string" `
                    -Value "$functionMethod" `
                    -Description "The name the method exposed by the FunctionApp that is referenced by the Logic App."
            }
        }
    }

    Out-TaskFileArm -InputObject $armObj
}