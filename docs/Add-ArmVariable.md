---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Add-ArmVariable

## SYNOPSIS
Add new variable to the ARM template

## SYNTAX

```
Add-ArmVariable [-InputObject] <Object> [-Name] <String> [-Value] <Object> [<CommonParameters>]
```

## DESCRIPTION
Adds or overwrites an ARM template variable by the name provided, and allows you to specify the value

## EXAMPLES

### EXAMPLE 1
```
Add-ArmVariable -InputObject $armObj -Name "logicAppName" -Value "TestLogicApp"
```

Creates / updates the logicAppName ARM template variable
Sets the value to: TestLogicApp

## PARAMETERS

### -InputObject
The ARM object that you want to work against

It has to be a object of the type \[ArmTemplate\] for it to work properly

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the variable that you want to work against

If the variable exists, the value gets overrided otherwise a new variable is added to the list of variables

```yaml
Type: String
Parameter Sets: (All)
Aliases: VariableName

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The value, that you want to assign to the ARM template variable

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
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
