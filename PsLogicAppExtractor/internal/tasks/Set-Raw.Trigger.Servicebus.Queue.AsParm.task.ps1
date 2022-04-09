$parm = @{
    Description = @"
Creates a LogicApp parm (parameter): TriggerQueue
-Sets the default value to the original value, extracted from inputs.path
--Sets the inputs.path value to: ...encodeURIComponent(parameters('TriggerQueue')))}/messages/...
"@
    Alias       = "Raw.Set-Raw.Trigger.Servicebus.Queue.AsParm"
}

Task -Name "Set-Raw.Trigger.Servicebus.Queue.AsParm" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath

    if ($lgObj.properties.definition.triggers.PsObject.Properties.Value.type -eq "ApiConnection" -and
        $lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path -like "*messages*") {
            
        if (-not ($lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path -like "*parameters('*')*")) {
            if ($lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path -match "'(.*)'") {
                
                $parmName = "TriggerQueue"
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value "$($Matches[1])"

                $lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path = $lgObj.properties.definition.triggers.PsObject.Properties.Value.inputs.path.Replace($Matches[0], "parameters('$parmName')")
            }
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}