$parm = @{
    Description = @"
Loops all Arm parameters
Identity known parameters and gives them a sorting value
-Custom parameters are assigned a "neutral" sorting value
Sorts parameters and re-assign them to the Arm template
"@
    Alias       = "Arm.Sort-Arm.Parameter"
}

Task -Name "Sort-Arm.Parameter" @parm -Action {
    Set-TaskWorkDirectory

    $armObj = Get-TaskWorkObject

    $connectionPattern = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value "*"
    $parmPattern = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value "*"
    $tagPattern = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value "*"
    
    $sorted = @(foreach ($item in $armObj.parameters.PsObject.Properties) {
            switch -Wildcard ($item.Name) {
                "logicApp*" { [PsCustomObject]@{Sort = 0; Name = $item.Name; Value = $item.Value } }
                "trigger*" { [PsCustomObject]@{Sort = 100; Name = $item.Name; Value = $item.Value } }
                "userAssignedIdentityName" { [PsCustomObject]@{Sort = 200; Name = $item.Name; Value = $item.Value } }
                "$connectionPattern" { [PsCustomObject]@{Sort = 300; Name = $item.Name; Value = $item.Value } }
                "$parmPattern" { [PsCustomObject]@{Sort = 100000; Name = $item.Name; Value = $item.Value } }
                "$tagPattern" { [PsCustomObject]@{Sort = 1000000; Name = $item.Name; Value = $item.Value } }
                default { [PsCustomObject]@{Sort = 1000; Name = $item.Name; Value = $item.Value } }
            }
        }) | Sort-Object -Property Sort

    $orderedParms = [ordered]@{}

    $groups = $sorted | Group-Object -Property Sort

    foreach ($item in $groups) {
        $item.Group | Sort-Object -Property Name | ForEach-Object {
            $orderedParms."$($_.Name)" = $_.Value
        }
    }

    $armObj.parameters = [PsCustomObject]$orderedParms

    Out-TaskFileArm -InputObject $armObj
}