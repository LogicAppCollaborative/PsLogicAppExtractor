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
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath
    
    $counter = 0
    $lgObj.properties.definition.actions.PsObject.properties | ForEach-Object {
        if ($_.Value.type -eq "Http" -and $_.Value.inputs.uri -like "*http*") {
            
            if ($_.Value.inputs.uri -match "^.+?[^\/:](?=[?\/]|$)") {
                $counter += 1

                $parmName = "EndpointUri$($counter.ToString().PadLeft(3, "0"))"
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value $Matches[0]

                $_.Value.inputs.uri = $_.Value.inputs.uri.Replace($Matches[0], "@{parameters('$parmName')}")
            }
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}