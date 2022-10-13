---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Update-PsLaArmParameterFile

## SYNOPSIS
Update parameter file from another file.

## SYNTAX

```
Update-PsLaArmParameterFile [-Source] <String> [-Destination] <String> [-KeepDestinationParameters]
 [-KeepValues] [[-ExcludeSourceParameters] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Update parameter file values from another file.

The source file can be an ARM template file or a parameter file.

## EXAMPLES

### EXAMPLE 1
```
Update-PsLaArmParameterFile -Source C:\Temp\Source.json -Destination C:\Temp\Destination.json
```

This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.json.
It will only update the parameter values that are present in the destination file.

This example illustrates how to update a parameter file from an ARM template file.

### EXAMPLE 2
```
Update-PsLaArmParameterFile -Source C:\Temp\Source.parameters.json -Destination C:\Temp\Destination.json
```

This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.parameters.json.
It will only update the parameter values that are present in the destination file.

This example illustrates how to update a parameter file from a parameter file.

### EXAMPLE 3
```
Update-PsLaArmParameterFile -Source C:\Temp\Source.parameters.json -Destination C:\Temp\Destination.json -KeepUnusedParameters
```

This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.parameters.json.
It will only update the parameter values that are present in the destination file.
It will keep the parameters in the destination file that are not in the source file.

This example illustrates how to update a parameter file from a parameter file.

### EXAMPLE 4
```
Update-PsLaArmParameterFile -Source C:\Temp\Source.parameters.json -Destination C:\Temp\Destination.json KeepValues
```

This will update the parameter file C:\Temp\Destination.json with the values from the parameter file C:\Temp\Source.parameters.json.
It will only update the parameter values that are present in the destination file.
It will keep the values of the parameters in the destination file.

This example illustrates how to update a parameter file from a parameter file.

## PARAMETERS

### -Source
The path to the source file to be used as the changes you want to apply.

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
The path to the destination parameter file to be updated.

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

### -KeepDestinationParameters
If you want to keep the parameters in the destination file that are not in the source file, set this switch.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: KeepUnusedParameters

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeepValues
If you want to keep the values of the parameters in the destination file, set this switch.

Useful when you want to align parameters across "environments", but don't want to change the values of the parameters.

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

### -ExcludeSourceParameters
If you want to exclude parameters from the source file from the update, set this switch.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
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
