$parm = @{
    Description = @"
Creates an Arm variable: userAssignedIdentityName
-Sets the default value to the original name, extracted from Microsoft.ManagedIdentity/userAssignedIdentities/XYZ
Sets the value for all references to: [resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', variables('UserAssignedIdentityName'))]
"@
    Alias       = "Arm.Set-Arm.UserAssignedIdentities.ResourceId.AsVariable"
}

Task -Name "Set-Arm.UserAssignedIdentities.ResourceId.AsVariable" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $raw = Get-TaskWorkRaw

    if ($raw -match '"/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ManagedIdentity/userAssignedIdentities/(.*)"') {
        $temp = $raw.Replace($Matches[0], "`"[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', variables('UserAssignedIdentityName'))]`"")

        $armObj = $temp | ConvertFrom-Json

        $armObj = Add-ArmVariable -InputObject $armObj -Name "userAssignedIdentityName" -Value $Matches[1]
    }
    else {
        $armObj = $raw | ConvertFrom-Json
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}