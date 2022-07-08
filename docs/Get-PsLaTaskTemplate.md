---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaTaskTemplate

## SYNOPSIS
Short description

## SYNTAX

```
Get-PsLaTaskTemplate [-Category] <String> [[-OutputPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaTaskTemplate -Category "Arm"
```

Outputs the task template of the type Arm to the console

### EXAMPLE 2
```
Get-PsLaTaskTemplate -Category "Arm" -OutputPath "C:\temp\work_directory"
```

Outputs the task template of the type Arm
Persists the file into the "C:\temp\work_directory" directory

## PARAMETERS

### -Category
Instruct the cmdlet which template type you want to have outputted

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

### -OutputPath
Path to were the Task template file will be persisted

The path has to be a directory

The file will be named: _set-XYA.Template.ps1

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Mötz Jensen (@Splaxi)

## RELATED LINKS
