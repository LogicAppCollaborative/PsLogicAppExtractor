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
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath
    
    $counter = 0
    $lgObj.properties.definition.actions.PsObject.properties | ForEach-Object {
        if ($_.Value.type -eq "ApiConnection" -and $_.Value.inputs.path -like "*messages*") {
            
            if (-not ($_.Value.inputs.path -like "*parameters('*')*")) {

                if ($_.Value.inputs.path -match "'(.*)'") {
                    $counter += 1
                    
                    $parmName = "Queue$($counter.ToString().PadLeft(3, "0"))"
                    $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                        -Type "string" `
                        -Value "$($Matches[1])"

                    $_.Value.inputs.path = $_.Value.inputs.path.Replace($Matches[0], "parameters('$parmName')")
                }
            }
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}