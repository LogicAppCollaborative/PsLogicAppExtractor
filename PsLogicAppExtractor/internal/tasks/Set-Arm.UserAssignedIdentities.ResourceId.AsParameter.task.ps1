$parm = @{
    Description = @"
Creates an Arm parameter: userAssignedIdentityName
-Sets the default value to the original name, extracted from Microsoft.ManagedIdentity/userAssignedIdentities/XYZ
Sets the value for all references to: [resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('UserAssignedIdentityName'))]
"@
    Alias       = "Arm.Set-Arm.UserAssignedIdentities.ResourceId.AsParameter"
}

Task -Name "Set-Arm.UserAssignedIdentities.ResourceId.AsParameter" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $raw = Get-TaskWorkRaw

    if ($raw -match '"/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ManagedIdentity/userAssignedIdentities/(.*)"') {
        $temp = $raw.Replace($Matches[0], "`"[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('UserAssignedIdentityName'))]`"")

        $armObj = $temp | ConvertFrom-Json

        $armObj = Add-ArmParameter -InputObject $armObj -Name "userAssignedIdentityName" `
            -Type "string" `
            -Value $Matches[1] `
            -Description "The name of the Managed Identity (UserAssignedIdentity) that will be utilized inside of the Logic App. Should be name of the object and not the id."
    }
    else {
        $armObj = $raw | ConvertFrom-Json
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}