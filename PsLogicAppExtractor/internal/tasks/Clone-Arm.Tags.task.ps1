$parm = @{
    Description = @"
"@
    Alias       = "Arm.Clone-Arm.Tags"
}

Task -Name "Clone-Arm.Tags" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $valueObj = [ordered]@{}
    $armObj.resources[0].tags.PsObject.Properties | ForEach-Object {
        $valueObj.Add($_.Name, $_.Value)
    }

    for ($i = 1; $i -lt $armObj.resources.Count; $i++) {
        
        if ($null -eq $armObj.resources[$i].tags) {
            $armObj.resources[$i] | Add-Member -MemberType NoteProperty -Name "tags" -Value $valueObj
        }
        else {
            $armObj.resources[$i].tags = $($valueObj)
        }
    }


    Out-TaskFileArm -InputObject $armObj
}