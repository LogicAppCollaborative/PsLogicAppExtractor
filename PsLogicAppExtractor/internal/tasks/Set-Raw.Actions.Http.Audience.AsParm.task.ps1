$parm = @{
    Description = @"
Loops all actions
-Identifies all HTTP
--Creates a LogicApp parm (parameter), with prefix & suffix
---Sets the default value (LogicApp parm) to the original value, extracted from authentication.audience
---Sets the authentication.audience value to: @{parameters('XYZ')}
"@
    Alias       = "Raw.Set-Raw.Actions.Http.Audience.AsParm"
}

Task -Name "Set-Raw.Actions.Http.Audience.AsParm" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    
    $counter = 0
    $actions = $lgObj.properties.definition.actions.PsObject.Properties | ForEach-Object { Get-ActionsByType -InputObject $_ -Type "Http" }

    foreach ($item in $actions) {
        if ($item.Value.inputs.authentication -and (-not ($item.Value.inputs.authentication.audience -like "*parameters('*')*"))) {
            if (-not [System.String]::IsNullOrEmpty($item.Value.inputs.authentication.audience)) {
                $counter += 1
                            
                $orgAudience = $item.Value.inputs.authentication.audience
                $parmName = "EndpointAudience$($counter.ToString().PadLeft(3, "0"))"
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value $orgAudience
            
                $item.Value.inputs.authentication.audience = "@{parameters('$parmName')}"
            }
        }
    }

    Out-TaskFileLogicApp -InputObject $lgObj
}