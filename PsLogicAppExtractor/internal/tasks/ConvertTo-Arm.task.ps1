$parm = @{
    Description = "Converts the LogicApp json structure into a valid ARM template json"
    Alias       = "Converter.ConvertTo-Arm"
}

Task -Name "ConvertTo-Arm" @parm -Action {
    Set-TaskWorkDirectory
    
    $lgObj = Get-TaskWorkObject

    $armObj = [ArmTemplate][PSCustomObject]@{
        '$schema'      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{}
        variables      = @{}
        outputs        = @{}
    }

    $armObj.resources = @($lgObj)
    
    Out-TaskFileArm -InputObject $armObj
}
