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
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath

    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    $armObj.resources[0].tags.PsObject.Properties | ForEach-Object {
        $namePreSuf = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value $($_.Name)

        $armObj = Add-ArmVariable -InputObject $armObj -Name "$namePreSuf" -Value $($_.Value)
        $_.Value = "[variables('$namePreSuf')]"
    }

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}