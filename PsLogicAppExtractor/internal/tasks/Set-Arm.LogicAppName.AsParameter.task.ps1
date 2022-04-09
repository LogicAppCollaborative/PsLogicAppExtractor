$parm = @{
    Description = @"
Creates an Arm parameter: logicAppName
-Sets the default value to the original name
"@
    Alias       = "Arm.Set-Arm.LogicAppName.AsParameter"
}

Task -Name "Set-Arm.LogicAppName.AsParameter" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath
    $orgName = $armObj.resources[0].name
    
    $armObj = Add-ArmParameter -InputObject $armObj -Name "logicAppName" `
        -Type "string" `
        -Value "$orgName" `
        -Description "Name of the Logic App. Makes it possible to override the name at deploy time."
    $armObj.resources[0].name = "[parameters('logicAppName')]"

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}