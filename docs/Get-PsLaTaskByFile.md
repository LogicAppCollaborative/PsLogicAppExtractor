---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaTaskByFile

## SYNOPSIS
Get tasks that are references from a file

## SYNTAX

```
Get-PsLaTaskByFile [-File] <String> [[-Category] <String>] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
Get tasks that are references from a runbook file, to make it easier to understand what a given runbook file is doing

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaTaskByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1"
```

List all tasks that are referenced from the file
The file needs to be a valid PSake runbook file

Output example:

Category  Name                     Description
--------  ----                     -----------
Converter ConvertTo-Arm            Converts the LogicApp json structure into a valid ARM template json
Converter ConvertTo-Raw Converts the raw LogicApp json structure into the a valid LogicApp json,…
Exporter  Export-LogicApp.AzCli    Exports the raw version of the Logic App from the Azure Portal

### EXAMPLE 2
```
Get-PsLaTaskByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -Category Converter
```

List all tasks that are referenced from the file, which are in the Converter category
The file needs to be a valid PSake runbook file

Output example:

Category  Name                     Description
--------  ----                     -----------
Converter ConvertTo-Arm            Converts the LogicApp json structure into a valid ARM template json
Converter ConvertTo-Raw Converts the raw LogicApp json structure into the a valid LogicApp json,…

### EXAMPLE 3
```
Get-PsLaTaskByFile -File "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -Detailed
```

List all tasks that are referenced from the file, and outputs it in the detailed view
The file needs to be a valid PSake runbook file

Output example:

Category    : Converter
Name        : ConvertTo-Arm
Description : Converts the LogicApp json structure into a valid ARM template json

Category    : Converter
Name        : ConvertTo-Raw
Description : Converts the raw LogicApp json structure into the a valid LogicApp json,
this will remove different properties that are not needed

Category    : Exporter
Name        : Export-LogicApp.AzCli
Description : Exports the raw version of the Logic App from the Azure Portal

## PARAMETERS

### -File
Path to the runbook file, that you want to analyze

```yaml
Type: String
Parameter Sets: (All)
Aliases: Runbook

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
Used to filter the number of tasks down to only being part of the category that you are looking for

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

### -Detailed
Instruct the cmdlet to output the details about the tasks in a more detailed fashion, makes it easier to read the descriptions for each task

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
