$parm = @{
    Description = @"
Loops all LogicApp tag
Sorts tags and re-assign them to the Logic App json structure
"@
    Alias       = "Raw.Sort-Raw.LogicApp.Tag"
}

Task -Name "Sort-Raw.LogicApp.Tag" @parm -Action {
    Set-TaskWorkDirectory

    $lgObj = Get-TaskWorkObject

    $sorted = @(foreach ($item in $lgObj.tags.PsObject.Properties) {
            switch -Wildcard ($item.Name) {
                
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

    $lgObj.tags = [PsCustomObject]$orderedParms

    Out-TaskFileLogicApp -InputObject $lgObj
}