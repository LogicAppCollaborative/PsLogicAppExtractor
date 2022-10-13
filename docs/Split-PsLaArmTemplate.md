---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Split-PsLaArmTemplate

## SYNOPSIS
Split an ARM template into multiple files, based on the resource type

## SYNTAX

```
Split-PsLaArmTemplate [-Path] <String> [[-OutputPath] <String>] [[-TypeFilter] <String>] [<CommonParameters>]
```

## DESCRIPTION
You might have a large ARM template, consisting of multiple resource types.
This script will create single ARM templates for the specified resource type, and will copy the parameters from the original template

## EXAMPLES

### EXAMPLE 1
```
Split-ArmTemplate -Path 'C:\temp\template.json' -OutputPath 'C:\temp\output'
```

This will create a new ARM template file for each resource of the type 'Microsoft.Web/connections' in the original ARM template file.
The new ARM template files will be persisted in the 'C:\temp\output' directory.

### EXAMPLE 2
```
Split-ArmTemplate -Path 'C:\temp\template.json'
```

This will create a new ARM template file for each resource of the type 'Microsoft.Web/connections' in the original ARM template file.
The new ARM template files will be persisted in the same directory as the original ARM template file.

### EXAMPLE 3
```
Split-ArmTemplate -Path 'C:\temp\template.json' -TypeFilter 'Microsoft.Web/sites'
```

This will create a new ARM template file for each resource of the type 'Microsoft.Web/sites' in the original ARM template file.
The new ARM template files will be persisted in the same directory as the original ARM template file.

## PARAMETERS

### -Path
Path to the ARM template that you want to work against

```yaml
Type: String
Parameter Sets: (All)
Aliases: File

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Path to were the ARM template file will be persisted

The path has to be a directory

The file will be named as the original ARM template file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TypeFilter
Instruct the cmdlet to only process the specified resource type

The default value is 'Microsoft.Web/connections'

```yaml
Type: String
Parameter Sets: (All)
Aliases: ResourceType

Required: False
Position: 3
Default value: Microsoft.Web/connections
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Mötz Jensen (@Splaxi)

## RELATED LINKS
