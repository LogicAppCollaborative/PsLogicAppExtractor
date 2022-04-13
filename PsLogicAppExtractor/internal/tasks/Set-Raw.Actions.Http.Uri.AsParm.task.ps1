$parm = @{
    Description = @"
Loops all actions
-Identifies all HTTP
--Creates a LogicApp parm (parameter), with prefix & suffix
---Sets the default value (LogicApp parm) to the original value, extracted from inputs.uri
---Sets the inputs.uri value to: @{parameters('XYZ')}
"@
    Alias       = "Raw.Set-Raw.Actions.Http.Uri.AsParm"
}

Task -Name "Set-Raw.Actions.Http.Uri.AsParm" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    
    $counter = 0
    $actions = $lgObj.properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Http" }

    foreach ($item in $actions) {
        if ($item.Value.inputs.uri -like "*http*") {
            if ($item.Value.inputs.uri -match "^.+?[^\/:](?=[?\/]|$)" -and (-not ($item.Value.inputs.uri -like "*parameters('*')*"))) {
                $counter += 1
                            
                $parmName = "EndpointUri$($counter.ToString().PadLeft(3, "0"))"
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value $Matches[0]

                $item.Value.inputs.uri = $item.Value.inputs.uri.Replace($Matches[0], "@{parameters('$parmName')}")
            }
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}