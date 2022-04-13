$parm = @{
    Description = @"
Converts the exported LogicApp json structure into the a valid LogicApp json,
this will remove different properties that are not needed
"@
    Alias       = "Converter.ConvertTo-Raw"
}

Task -Name "ConvertTo-Raw" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject

    Out-TaskFileLogicApp -InputObject $lgObj
}