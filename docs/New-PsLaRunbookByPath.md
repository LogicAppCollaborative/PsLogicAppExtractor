---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# New-PsLaRunbookByPath

## SYNOPSIS
Create valid runbook file based on the task files in the directory

## SYNTAX

```
New-PsLaRunbookByPath [[-Path] <String>] [[-SubscriptionId] <String>] [[-ResourceGroup] <String>]
 [[-Name] <String>] [[-OutputPath] <String>] [-IncludePrefixSuffix] [<CommonParameters>]
```

## DESCRIPTION
Helps you build a valid runbook file, based on all the individual task files (ps1) that are located in the directory

This makes it easy to get a starting point for a new runbook file, based on the tasks you have persisted as individual files

Especially helpful for custom tasks that might be stored in a central repository

The task files has to valid PSake tasks saved as ps1 files

## EXAMPLES

### EXAMPLE 1
```
New-PsLaRunbookByPath
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes

### EXAMPLE 2
```
New-PsLaRunbookByPath -Path c:\temp\tasks
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Reads all ps1 files located in c:\temp\tasks

Great to use when you have lots of custom tasks in a directory / repository, and want a good runbook file as starting point

### EXAMPLE 3
```
New-PsLaRunbookByPath -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg"
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
Prepares the Properties object with SubscriptionId and ResourceGroup

Useful if you have multiple logic apps in the same resource group and you want them extracted using the same runbook file

### EXAMPLE 4
```
New-PsLaRunbookByPath -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
Prepares the Properties object with SubscriptionId and ResourceGroup and Name

Useful if you want to have a ready to run runbook file, that makes it simple to run the command again and again
Great for iterative work, where you make lots of small changes in the logic app and want to see how the changes affect your ARM template

### EXAMPLE 5
```
New-PsLaRunbookByPath -OutputPath c:\temp\PsLaRunbooks
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
Outputs the build to c:\temp\PsLaRunbooks

The runbook file is default named: PsLaExtractor.default.psakefile.ps1

### EXAMPLE 6
```
New-PsLaRunbookByPath -IncludePrefixSuffix
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Reads all the internal / generic tasks that are part of the module and implements a valid default path for the includes
The Properties object inside the runbook file, will be pre-populated with the default prefix and suffix values from the module

This make it easier to make the runbook file work across different environments, without having to worry about prepping different prefix and suffix value prior

## PARAMETERS

### -Path
Path to the directory where there are valid PSake tasks saved as ps1 files

The default value is set for the internal directory where all the generic tasks that are part of the module is located

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Tasks)
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionId
Id of the subscription that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session either needs to be "connected" to the subscription or at least have permissions to work against the subscription

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

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

### -ResourceGroup
Name of the resource group that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session needs to have permissions to work against the resource group

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

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

### -Name
Name of the logic app, that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session needs to have permissions to work against the logic app

Useful when you know upfront what you want to work against, as you don't need to pass the parameter into the Invoke-PsLaExtractor

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Path to were the runbook file will be persisted

The path has to be a directory

The runbook file will be named: PsLaExtractor.default.psakefile.ps1

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

### -IncludePrefixSuffix
Instruct the cmdlet to add the different prefix and suffix options, with the default values that comes with the module

This make it easier to make the runbook file work across different environments, without having to worry about prepping different prefix and suffix value prior

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
