---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-ExtractOutput

## SYNOPSIS
Get the output file

## SYNTAX

```
Get-ExtractOutput [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Get the full path of the "latest" file from the workpath of the runbook / extraction process

## EXAMPLES

### EXAMPLE 1
```
Get-ExtractOutput -Path "C:\temp\work_directory"
```

Returns the full path of the latest written file from the "C:\temp\work_directory" path

## PARAMETERS

### -Path
Path to the workpath where the runbook has been persisting files

```yaml
Type: String
Parameter Sets: (All)
Aliases: WorkPath

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

## RELATED LINKS
