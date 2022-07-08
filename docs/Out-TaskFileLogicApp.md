---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Out-TaskFileLogicApp

## SYNOPSIS
Output the tasks result to a file, as a LogicApp json structure

## SYNTAX

```
Out-TaskFileLogicApp [-InputObject] <Object> [<CommonParameters>]
```

## DESCRIPTION
Persists the tasks output into a file, as a LogicApp json structure

Notes: It is considered as an internal function, and should not be used directly.

## EXAMPLES

### EXAMPLE 1
```
Out-TaskFileLogicApp -InputObject $lgObj
```

Outputs the armObj variable
The armObj is casted to the \[ArmTemplate\] type, to ensure it is persisted as the expected json structure

## PARAMETERS

### -InputObject
The object that should be written to the desired path

Will be converted to a json string, usign the ConvertTo-Json

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Mötz Jensen (@Splaxi)

This is considered as an internal function, and should not be used directly.

## RELATED LINKS
