---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Format-Name

## SYNOPSIS
Format the name with the prefix and suffix

## SYNTAX

```
Format-Name [-Type] <String> [[-Prefix] <String>] [[-Suffix] <String>] [-Value] <String> [<CommonParameters>]
```

## DESCRIPTION
Format the name with the prefix and suffix

If the passed prefix and suffix is not $null, then they are used

Otherwise the cmdlet will default back to the configuration for each type, that is persisted in the configuration store

Notes: It is considered as an internal function, and should not be used directly.

## EXAMPLES

### EXAMPLE 1
```
Format-Name -Type "Tag" -Value "CostCenter"
```

Formats the value: CostCenter with the default prefix and suffix for the type: Tag
The default prefix is: tag_
The default suffix is: $null

The output will be: tag_CostCenter

## PARAMETERS

### -Type
The type of name that you want to work against

Allowed values:
Tag
Connection
Parameter
Parm

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

### -Prefix
The prefix that you want to append to the name

If empty / $null - then the cmdlet will use the prefix that is stored for the specific type

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

### -Suffix
The suffix that you want to append to the name

If empty / $null - then the cmdlet will use the suffix that is stored for the specific type

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The string value that you want to have the prefix and suffix concatenated with

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

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
