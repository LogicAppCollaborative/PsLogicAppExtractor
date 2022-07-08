
<#
    .SYNOPSIS
        Update parameter file from another file.
        
    .DESCRIPTION
        Update parameter file values from another file.
        
        The source file can be an ARM template file or a parameter file.
        
    .PARAMETER Source
        The path to the source file to be used as the changes you want to apply.
        
    .PARAMETER Destination
        The path to the destination parameter file to be updated.
        
    .EXAMPLE
        PS C:\> Update-PsLaArmParameterFile -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json
        
        This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.json.
        It will only update the parameter values that are present in the destination file.
        
        This example illustrates how to update a parameter file from an ARM template file.
        
    .EXAMPLE
        PS C:\> Update-PsLaArmParameterFile -Source C:\Temp\Source.parameters.json -Destination C:\Temp\Destination.json
        
        This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.parameters.json.
        It will only update the parameter values that are present in the destination file.
        
        This example illustrates how to update a parameter file from a parameter file.
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
#>
function Update-PsLaArmParameterFile {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [string] $Source,

        [parameter(Mandatory = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [string] $Destination
    )

    process {
        #The task counter needs to be reset prior running
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0

        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value ""
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskOutputFile -Value ""
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskPath -Value ""
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.Name -Value ""
                
        $armObjSource = Get-TaskWorkObject -Path $Source
        $armObjDestination = Get-TaskWorkObject -Path $Destination

        foreach ($item in $armObjDestination.parameters.PsObject.Properties) {
            $valueObj = [ordered]@{}
            
            if ($armObjSource.parameters."$($item.Name)".DefaultValue) {
                $valueObj.value = $armObjSource.parameters."$($item.Name)".DefaultValue
            }
            else {
                $valueObj.value = $armObjSource.parameters."$($item.Name)".Value
            }

            $armObjDestination.parameters."$($item.Name)" = $valueObj
        }

        Out-TaskFile -Path $Destination -InputObject $armObjDestination
    }
}