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

    $PrefixConnection = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.connection.prefix
    $connectionPattern = Format-Name -Type "Connection" -Prefix $PrefixConnection -Value "*"

    $PrefixParm = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.parm.prefix
    $parmPattern = Format-Name -Type "Parm" -Prefix $PrefixParm -Value "*"

    $PrefixTag = Get-PSFConfigValue -FullName PsLogicAppExtractor.prefixsuffix.tag.prefix
    $tagPattern = Format-Name -Type "Tag" -Prefix $PrefixTag -Value "*"
    
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