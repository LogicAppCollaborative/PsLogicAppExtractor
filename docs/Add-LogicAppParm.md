---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Add-LogicAppParm

## SYNOPSIS
Add new parm (parameter) to the LogicApp object

## SYNTAX

```
Add-LogicAppParm [-InputObject] <Object> [-Name] <String> [-Type] <String> [-Value] <Object>
 [<CommonParameters>]
```

## DESCRIPTION
Adds or overwrites a LogicApp parm (parameter) by the name provided, and allows you to specify the default value and the type

Notes: It is considered as an internal function, and should not be used directly.

## EXAMPLES

### EXAMPLE 1
```
Add-LogicAppParm -InputObject $lgObj -Name "TriggerQueue" -Type "string" -Value "Inbound"
```

Creates / updates the TriggerQueue LogicApp parm (parameter)
Sets the type of the parameter to: string
Sets the default value to: Inbound

## PARAMETERS

### -InputObject
The ARM object that you want to work against

It has to be a object of the type \[LogicApp\] for it to work properly

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
Name of the parm (parameter) that you want to work against

If the parm (parameter) exists, the value gets overrided otherwise a new parm (parameter) is added to the list of parms (parameters)

```yaml
Type: String
Parameter Sets: (All)
Aliases: ParmName

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The type of the LogicApp parm (parameter)

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
The default value, that you want to assign to the LogicApp parm (parameter)

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Mötz Jensen (@Splaxi)

This is considered as an internal function, and should not be used directly.

## RELATED LINKS
