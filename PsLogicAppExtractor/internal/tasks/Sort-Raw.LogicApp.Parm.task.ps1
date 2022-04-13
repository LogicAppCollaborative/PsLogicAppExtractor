$parm = @{
    Description = @"
Loops all LogicApp parm (parameter)
Sorts parms (parameters) and re-assign them to the Logic App json structure
"@
    Alias       = "Raw.Sort-Raw.LogicApp.Parm"
}

Task -Name "Sort-Raw.LogicApp.Parm" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject
    
    $sorted = @(foreach ($item in $lgObj.properties.definition.parameters.PsObject.Properties) {
            switch -Wildcard ($item.Name) {
                '$connections' { [PsCustomObject]@{Sort = 0; Name = $item.Name; Value = $item.Value } }
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

    $lgObj.properties.definition.parameters = [PsCustomObject]$orderedParms

    Out-TaskFileLogicApp -InputObject $lgObj
}