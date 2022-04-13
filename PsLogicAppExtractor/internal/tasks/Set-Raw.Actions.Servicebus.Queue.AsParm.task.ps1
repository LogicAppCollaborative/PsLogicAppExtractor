$parm = @{
    Description = @"
Loops all actions
-Identifies all Servicebus
--Creates a LogicApp parm (parameter), with prefix & suffix
---Sets the default value (LogicApp parm) to the original value, extracted from inputs.path
---Sets the inputs.path value to: ...encodeURIComponent(parameters('XYZ')))}/messages/...
"@
    Alias       = "Raw.Set-Arm.Connections.ManagedApis.AsParameter"
}

Task -Name "Set-Raw.Actions.Servicebus.Queue.AsParm" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject
    
    $counter = 0

    $actions = $lgObj.properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "ApiConnection" }

    foreach ($item in $actions) {
        if ($item.Value.inputs.path -like "*messages*") {
            if (-not ($item.Value.inputs.path -like "*parameters('*')*")) {

                if ($item.Value.inputs.path -match "'(.*)'") {
                    $counter += 1
                                
                    $parmName = "Queue$($counter.ToString().PadLeft(3, "0"))"
                    $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                        -Type "string" `
                        -Value "$($Matches[1])"
            
                    $item.Value.inputs.path = $item.Value.inputs.path.Replace($Matches[0], "parameters('$parmName')")
                }
            }
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}