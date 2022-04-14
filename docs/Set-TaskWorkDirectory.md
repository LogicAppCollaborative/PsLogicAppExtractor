---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Set-TaskWorkDirectory

## SYNOPSIS
Set the current working directory

## SYNTAX

```
Set-TaskWorkDirectory [[-Path] <String>] [[-FileName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Sets the current tasks working directory, based on the current PsLaWorkPath and the execution number that task is in the overall execution

Outputs the path that has been constructed

## EXAMPLES

### EXAMPLE 1
```
Set-TaskWorkDirectory
```

Creates a new sub directory under the $PsLaWorkPath location
The sub directory is named "$taskCounter\`_$TaskName"

The output will be: "$Path\$taskCounter\`_$TaskName"

## PARAMETERS

### -Path
Path to the current working directory

The value passed in should always be the $PsLaWorkPath, to ensure that things are working

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.WorkPath)
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileName
The of the file that you want to be configured for the task

Is normally equal to the name of the Logic App

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "$Name.json"
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
