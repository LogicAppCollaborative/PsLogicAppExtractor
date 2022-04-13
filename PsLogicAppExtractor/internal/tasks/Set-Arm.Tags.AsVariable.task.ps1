$parm = @{
    Description = @"
Loops all tags
-Creates an Arm variable, with prefix & suffix
--Sets the value (Arm variable) to the original value from the tag
-Sets the value (Tag) to: [variables('XYZ')]
"@
    Alias       = "Arm.Set-Arm.Tags.AsVariable"
}

Task -Name "Set-Arm.Tags.AsVariable" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $armObj.resources[0].tags.PsObject.Properties | ForEach-Object {
        $namePreSuf = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value $($_.Name)

        $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $($_.Value)
        $_.Value = "[variables('$namePreSuf')]"
    }

    Out-TaskFileArm -InputObject $armObj
}