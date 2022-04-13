$parm = @{
    Description = @"
Loops all tags
-Creates an Arm parameter, with prefix & suffix
--Sets the default value (Arm parameter) to the original value from the tag
-Sets the value (Tag) to: [parameters('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Tags.AsParameter"
}

Task -Name "Set-Arm.Tags.AsParameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].tags.PsObject.Properties | ForEach-Object {
        $namePreSuf = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value $_.Name

        $armObj = Add-ArmParameter -InputObject $armObj -Name "$namePreSuf" `
            -Type "string" `
            -Value "$($_.Value)" `
            -Description "Tag that is searchable inside the Azure platform, either with the GUI (portal.azure.com) or with scripting tools."

        $_.Value = "[parameters('$namePreSuf')]"
    }

    Out-TaskFileArm -InputObject $armObj
}