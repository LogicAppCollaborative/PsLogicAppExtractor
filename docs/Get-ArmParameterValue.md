---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-ArmParameterValue

## SYNOPSIS
Get the value from an ARM template parameter

## SYNTAX

```
Get-ArmParameterValue [-InputObject] <Object> [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Gets the current default value from the specified ARM template parameter

## EXAMPLES

### EXAMPLE 1
```
Get-ArmParameterValue -InputObject $armObj -Name "logicAppName"
```

Gets the default value from the ARM template parameter: logicAppName

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
Name of the parameter that you want to work against

```yaml
Type: String
Parameter Sets: (All)
Aliases: ParameterName

Required: True
Position: 2
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
