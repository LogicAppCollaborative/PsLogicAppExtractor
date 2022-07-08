---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Update-PsLaArmTemplate

## SYNOPSIS
Update ARM template from another ARM template.

## SYNTAX

```
Update-PsLaArmTemplate [-Source] <String> [-Destination] <String> [-SkipParameters] [-SkipResources]
 [-RemoveSource] [<CommonParameters>]
```

## DESCRIPTION
Update an ARM template, with the content of another ARM template.

You can update the entire ARM template, or just a part of it.

Supports the following options:
* Full
* SkipResources
* SkipParameters

## EXAMPLES

### EXAMPLE 1
```
Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json
```

This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
It will overwrite the entire ARM template, but will not remove the source ARM template.

### EXAMPLE 2
```
Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json -SkipParameters
```

This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
It will overwrite the entire ARM template, but leave the parameters alone.

### EXAMPLE 3
```
Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json -SkipResources
```

This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
It will overwrite the entire ARM template, but leave the resources alone.

### EXAMPLE 4
```
Update-PsLaArmTemplate -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json -RemoveSource
```

This will update the ARM template in C:\Temp\Destination.json from the ARM template in C:\Temp\Source.json.
It will overwrite the entire ARM template, and remove the source ARM template.

## PARAMETERS

### -Source
The path to the source ARM template to be used as the changes you want to apply.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Destination
The path to the destination ARM template to be updated.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipParameters
If true, then the parameters will not be updated.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipResources
If true, then the resources will not be updated.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveSource
If true, then the source ARM template will be removed after it has been used.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
