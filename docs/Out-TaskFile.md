---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Out-TaskFile

## SYNOPSIS
Output the tasks result to a file

## SYNTAX

### InputObject (Default)
```
Out-TaskFile [-Path <String>] -InputObject <Object> [<CommonParameters>]
```

### Content
```
Out-TaskFile [-Path <String>] -Content <String> [<CommonParameters>]
```

## DESCRIPTION
Persists the tasks output into a file, either the raw content or the object

Sets the $Script:FilePath = $Path, to ensure the next tasks can pick up the file and continue its work

Notes: It is considered as an internal function, and should not be used directly.

## EXAMPLES

### EXAMPLE 1
```
Out-TaskFile -Path "C:\temp\work_directory\1_Export-LogicApp.AzCli" -InputObject $([ArmTemplate]$armObj)
```

Outputs the armObj variable to the path: "C:\temp\work_directory\1_Export-LogicApp.AzCli"
The armObj is casted to the \[ArmTemplate\] type, to ensure it is persisted as the expected json structure

### EXAMPLE 2
```
Out-TaskFile -Path "C:\temp\work_directory\1_Export-LogicApp.AzCli" -Content '{"Test":"Test"}'
```

Outputs the content string: '{"Test":"Test"}' to the path: "C:\temp\work_directory\1_Export-LogicApp.AzCli"

## PARAMETERS

### -Path
Path to where the tasks wants the ouput to be persisted

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $(Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskOutputFile)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Content
Raw string that should be written to the desired path

```yaml
Type: String
Parameter Sets: Content
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
The object that should be written to the desired path

Will be converted to a json string, usign the ConvertTo-Json

Important note: If you need the InputObject to be written with a specific structure, the object has to be of the expected type before being passed into the cmdlet
A simple cast can ensure this to work as intended

```yaml
Type: Object
Parameter Sets: InputObject
Aliases:

Required: True
Position: Named
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
