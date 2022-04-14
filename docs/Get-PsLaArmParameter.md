---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaArmParameter

## SYNOPSIS
Get parameters from ARM template

## SYNTAX

```
Get-PsLaArmParameter [[-Path] <String>] [[-Exclude] <String[]>] [[-Include] <String[]>] [-AsFile]
 [-BlankValues] [-CopyMetadata] [<CommonParameters>]
```

## DESCRIPTION
Get parameters from the ARM template

You can include / exclude parameters, so your parameter file only contains the parameters you want to handle at deployment

The default value is promoted as the initial value of the parameter

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json"
```

Gets all parameters from the "TestLogicApp.json" ARM template
The output is written to the console

### EXAMPLE 2
```
Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -Exclude "logicAppLocation","trigger_Frequency"
```

Gets all parameters from the "TestLogicApp.json" ARM template
Will exclude the parameters "logicAppLocation" & "trigger_Frequency" if present
The output is written to the console

### EXAMPLE 3
```
Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -Include "trigger_Interval","trigger_Frequency"
```

Gets all parameters from the "TestLogicApp.json" ARM template
Will only copy over the parameters "trigger_Interval" & "trigger_Frequency" if present
The output is written to the console

### EXAMPLE 4
```
Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -AsFile
```

Gets all parameters from the "TestLogicApp.json" ARM template
The output is written the "C:\temp\work_directory\TestLogicApp.parameters.json" file

### EXAMPLE 5
```
Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -BlankValues
```

Gets all parameters from the "TestLogicApp.json" ARM template
Blank all values for each parameter
The output is written to the console

### EXAMPLE 6
```
Get-PsLaArmParameter -Path "C:\temp\work_directory\TestLogicApp.json" -CopyMetadata
```

Gets all parameters from the "TestLogicApp.json" ARM template
Copies over the metadata property from the original parameter, if present
The output is written to the console

## PARAMETERS

### -Path
Path to the ARM template that you want to work against

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
Instruct the cmdlet to exclude the given set of parameter names

Supports array / list

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
Instruct the cmdlet to include the given set of parameter names

Supports array / list

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

### -AsFile
Instruct the cmdlet to save a valid ARM template parameter file next to the ARM template file

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

### -BlankValues
Instructs the cmdlet to blank the values in the parameter file

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

### -CopyMetadata
Instructs the cmdlet to copy over the metadata property from the original parameter in the ARM template, if present

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
