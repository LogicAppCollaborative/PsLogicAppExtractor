---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaTaskByPath

## SYNOPSIS
Get tasks based on files from a directory

## SYNTAX

```
Get-PsLaTaskByPath [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Get tasks from individual files, that are located in a directory

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaTaskByPath -Path c:\temp\tasks
```

List all available tasks, based on the files in the directory
All files has to be valid PSake files saved as ps1 files

Output example:

Category    : Arm
Name        : Set-Arm.Connections.ManagedApis.AsParameter
Description : Loops all $connections childs
-Creates an Arm parameter, with prefix & suffix
--Sets the default value to the original name, extracted from connectionId property
-Sets the connectionId to: \[resourceId('Microsoft.Web/connections', parameters('XYZ'))\]
-Sets the connectionName to: \[parameters('XYZ')\]
Path        : c:\temp\tasks\Set-Arm.Connections.ManagedApis.AsParameter.task.ps1
File        : Set-Arm.Connections.ManagedApis.AsParameter.task.ps1

Category    : Arm
Name        : Set-Arm.Connections.ManagedApis.AsVariable
Description : Loops all $connections childs
-Creates an Arm variable, with prefix & suffix
--Sets the value to the original name, extracted from connectionId property
-Sets the connectionId to: \[resourceId('Microsoft.Web/connections', variables('XYZ'))\]
-Sets the connectionName to: \[variables('XYZ')\]
Path        : c:\temp\tasks\Set-Arm.Connections.ManagedApis.AsVariable.task.ps1
File        : Set-Arm.Connections.ManagedApis.AsVariable.task.ps1

## PARAMETERS

### -Path
Path to the directory where there are valid PSake tasks saved as ps1 files

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
