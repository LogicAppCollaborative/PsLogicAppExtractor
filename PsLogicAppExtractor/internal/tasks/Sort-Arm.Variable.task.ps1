$parm = @{
    Description = @"
Loops all Arm variables
Identity known variables and gives them a sorting value
-Custom variables are assigned a "neutral" sorting value
Sorts variables and re-assign them to the Arm template
"@
    Alias       = "Arm.Sort-Arm.Variable"
}

Task -Name "Sort-Arm.Variable" @parm -Action {
    if ($PsLaFilePath) { $Script:filePath = $PsLaFilePath }
    $filePath = Set-TaskWorkDirectory -Path $PsLaWorkPath -FilePath $Script:filePath
    
    $armObj = Get-TaskWorkObject -FilePath $Script:filePath

    $connectionPattern = Format-Name -Type "Connection" -Prefix $Connection_Prefix -Suffix $Connection_Suffix -Value "*"
    $parmPattern = Format-Name -Type "Parm" -Prefix $Parm_Prefix -Suffix $Parm_Suffix -Value "*"
    $tagPattern = Format-Name -Type "Tag" -Prefix $Tag_Prefix -Suffix $Tag_Suffix -Value "*"

    $sorted = @(foreach ($item in $armObj.variables.PsObject.Properties) {
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

    $armObj.variables = [PsCustomObject]$orderedParms

    Out-TaskFile -Path $filePath -InputObject $([ArmTemplate]$armObj)
}