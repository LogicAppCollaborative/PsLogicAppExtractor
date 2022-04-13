---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# New-PsLaRunbookByTask

## SYNOPSIS
Create valid runbook file based on the task passed as inputs

## SYNTAX

```
New-PsLaRunbookByTask [-Task] <String[]> [[-SubscriptionId] <String>] [[-ResourceGroup] <String>]
 [[-Name] <String>] [[-OutputPath] <String>] [-IncludePrefixSuffix] [<CommonParameters>]
```

## DESCRIPTION
Helps you build a valid runbook file, based on all the individual tasks that are passed as inputs

This makes it easy to get a starting point for a new runbook file, based on the tasks you have build in your array and then passes into the cmdlet

Tasks are expected to be the ones that are part of the module

## EXAMPLES

### EXAMPLE 1
```
New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm"
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks

### EXAMPLE 2
```
New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg"
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
Prepares the Properties object with SubscriptionId and ResourceGroup

Useful if you have multiple logic apps in the same resource group and you want them extracted using the same runbook file

### EXAMPLE 3
```
New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
Prepares the Properties object with SubscriptionId and ResourceGroup and Name

Useful if you want to have a ready to run runbook file, that makes it simple to run the command again and again
Great for iterative work, where you make lots of small changes in the logic app and want to see how the changes affect your ARM template

### EXAMPLE 4
```
New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -OutputPath c:\temp\PsLaRunbooks
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
Outputs the build to c:\temp\PsLaRunbooks

The runbook file is default named: PsLaExtractor.default.psakefile.ps1

### EXAMPLE 5
```
New-PsLaRunbookByTask -Task "Export-LogicApp.AzCli","ConvertTo-Raw","ConvertTo-Arm" -IncludePrefixSuffix
```

Creates a valid runbook file, based on the bare minimum and with sane default values
Will write the include and taskList in the mentioned order of the tasks
The Properties object inside the runbook file, will be pre-populated with the default prefix and suffix values from the module

This make it easier to make the runbook file work across different environments, without having to worry about prepping different prefix and suffix value prior

## PARAMETERS

### -Task
Names of the tasks that you want to be part of your runbook file

Supports array of task names

Names of the different tasks are expected to be the ones that are part of the module

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionId
Id of the subscription that you want to work against

At runtime / execution of Invoke-PsLaExtractor - your current powershell / az cli session either needs to "connected" to the subscription or at least have permissions to work against the subscription

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
