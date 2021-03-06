
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
        
    .PARAMETER KeepUnusedParameters
        If you want to keep the parameters in the destination file that are not in the source file, set this switch.
        
    .PARAMETER KeepValues
        If you want to keep the values of the parameters in the destination file, set this switch.

        Useful when you want to align parameters across "environments", but don't want to change the values of the parameters.

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

    .EXAMPLE
        PS C:\> Update-PsLaArmParameterFile -Source C:\Temp\Source.parameters.json -Destination C:\Temp\Destination.json -KeepUnusedParameters
        
        This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.parameters.json.
        It will only update the parameter values that are present in the destination file.
        It will keep the parameters in the destination file that are not in the source file.
        
        This example illustrates how to update a parameter file from a parameter file.
        
    .EXAMPLE
        PS C:\> Update-PsLaArmParameterFile -Source C:\Temp\Source.parameters.json -Destination C:\Temp\Destination.json KeepValues
        
        This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.parameters.json.
        It will only update the parameter values that are present in the destination file.
        It will keep the values of the parameters in the destination file.
        
        This example illustrates how to update a parameter file from a parameter file.

    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
#>
function Update-PsLaArmParameterFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [string] $Source,

        [parameter(Mandatory = $true)]
        [PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
        [string] $Destination,

        [switch] $KeepUnusedParameters,

        [switch] $KeepValues
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
            
            if (-not ($armObjSource.parameters."$($item.Name)") -and (-not $KeepUnusedParameters)) {
                $armObjDestination.parameters.PsObject.Properties.Remove($item.Name)
                continue
            }

            if ($KeepValues) {
                continue
            }

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