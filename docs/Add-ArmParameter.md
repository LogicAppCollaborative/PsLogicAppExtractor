---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Add-ArmParameter

## SYNOPSIS
Add new parameter to the ARM template

## SYNTAX

```
Add-ArmParameter [-InputObject] <Object> [-Name] <String> [-Type] <String> [-Value] <Object>
 [[-Description] <String>] [<CommonParameters>]
```

## DESCRIPTION
Adds or overwrites an ARM template parameter by the name provided, and allows you to specify the default value, type and the metadata decription

## EXAMPLES

### EXAMPLE 1
```
Add-ArmParameter -InputObject $armObj -Name "logicAppName" -Type "string" -Value "TestLogicApp"
```

Creates / updates the logicAppName ARM template parameter
Sets the type of the parameter to: string
Sets the default value to: TestLogicApp

### EXAMPLE 2
```
Add-ArmParameter -InputObject $armObj -Name "logicAppName" -Type "string" -Value "TestLogicApp" -Description "This is the name we extracted from the orignal LogicApp"
```

Creates / updates the logicAppName ARM template parameter
Sets the type of the parameter to: string
Sets the default value to: TestLogicApp
Sets the metadata description

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

If the parameter exists, the value gets overrided otherwise a new parameter is added to the list of parameters

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

### -Type
The type of the ARM template parameter

It supports all known types

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The default value, that you want to assign to the ARM template parameter

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
The metadata description that you want to assign to the ARM template parameters

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
