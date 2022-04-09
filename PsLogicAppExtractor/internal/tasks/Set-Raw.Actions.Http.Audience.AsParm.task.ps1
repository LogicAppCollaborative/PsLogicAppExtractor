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
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $lgObj = Get-TaskWorkObject -FilePath $Script:filePath
    
    $counter = 0
    $lgObj.properties.definition.actions.PsObject.properties | ForEach-Object {
        if ($_.Value.type -eq "Http" -and $_.Value.inputs.authentication) {
            
            if (-not [System.String]::IsNullOrEmpty($_.Value.inputs.authentication.audience)) {
                $counter += 1
                
                $orgAudience = $_.Value.inputs.authentication.audience
                $parmName = "EndpointAudience$($counter.ToString().PadLeft(3, "0"))"
                $lgObj = Remove-LogicAppParm -InputObject $lgObj -Name $parmName
                $lgObj = Add-LogicAppParm -InputObject $lgObj -Name $parmName `
                    -Type "string" `
                    -Value $orgAudience

                $_.Value.inputs.authentication.audience = "@{parameters('$parmName')}"
            }
        }
    }

    Out-TaskFile -Path $filePath -InputObject $([LogicApp]$lgObj)
}