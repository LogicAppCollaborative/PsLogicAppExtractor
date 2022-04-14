---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-TaskWorkRaw

## SYNOPSIS
Get the object that the task has to work against, as a raw string

## SYNTAX

```
Get-TaskWorkRaw [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets the object from the "previous" task, based on the persisted path and loads it into memory using Get-Content

## EXAMPLES

### EXAMPLE 1
```
Get-TaskWorkObject
```

Returns the object that is stored at the location passed in the Path parameter

## PARAMETERS

### -Path
Path to the file that you want the task to work against

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskInputNext)
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
