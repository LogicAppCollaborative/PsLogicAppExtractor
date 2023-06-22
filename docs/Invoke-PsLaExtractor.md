---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Invoke-PsLaExtractor

## SYNOPSIS
Execute the extractor process of the LogicApp

## SYNTAX

### PreppedFile (Default)
```
Invoke-PsLaExtractor -Runbook <String> [-Task <String[]>] [-WorkPath <String>] [-OutputPath <String>]
 [-KeepFiles] [-Tools <String>] [<CommonParameters>]
```

### Subscription
```
Invoke-PsLaExtractor -Runbook <String> -SubscriptionId <String> -ResourceGroup <String> -Name <String>
 [-Task <String[]>] [-WorkPath <String>] [-OutputPath <String>] [-KeepFiles] [-Tools <String>]
 [<CommonParameters>]
```

### ResourceGroup
```
Invoke-PsLaExtractor -Runbook <String> -ResourceGroup <String> -Name <String> [-Task <String[]>]
 [-WorkPath <String>] [-OutputPath <String>] [-KeepFiles] [-Tools <String>] [<CommonParameters>]
```

### NameOnly
```
Invoke-PsLaExtractor -Runbook <String> -Name <String> [-Task <String[]>] [-WorkPath <String>]
 [-OutputPath <String>] [-KeepFiles] [-Tools <String>] [<CommonParameters>]
```

## DESCRIPTION
Execute all the tasks that have been defined in the runbook file, and get an ARM template as output

Depending on the initial extractor task that you are using, your powershell / az cli session needs to be signed in

Your runbook file can contain the tasks available from the module, but also your own custom tasks, that you want to have executed as part of the process

## EXAMPLES

### EXAMPLE 1
```
Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp
```

Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake runbook file

### EXAMPLE 2
```
Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -SubscriptionId "f5608f3d-ab28-49d8-9b4e-1b1f812d12e0" -ResourceGroup "TestRg" -Name "TestLogicApp"
```

Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake runbook file

### EXAMPLE 3
```
Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1"
```

Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake runbook file
The runbook file needs to have populated the Properties object, with the minimum: ResourceGroup and SubscriptionId

### EXAMPLE 4
```
Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp -WorkPath "C:\temp\work_directory"
```

Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake runbook file
Will output all tasks files into the "C:\temp\work_directory" location

### EXAMPLE 5
```
Invoke-PsLaExtractor -Runbook "C:\temp\LogicApp.ExportOnly.psakefile.ps1" -ResourceGroup "TestRg" -Name TestLogicApp -KeepFiles
```

Invokes the different tasks inside the runbook file, to export the TestLogicApp as an ARM template
The file needs to be a valid PSake runbook file
All files that the different tasks has created, are keept, for the user to analyze them

## PARAMETERS

### -Runbook
Path to the PSake valid runbook file that you want to have executed while exporting, sanitizing and converting a LogicApp into a deployable ARM template

```yaml
Type: String
Parameter Sets: (All)
Aliases: File

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionId
Id of the subscription that you want to work against, your current powershell / az cli session either needs to be "connected" to the subscription or at least have permissions to work against the subscription

```yaml
Type: String
Parameter Sets: Subscription
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroup
Name of the resource group that you want to work against, your current powershell / az cli session needs to have permissions to work against the resource group

```yaml
Type: String
Parameter Sets: Subscription, ResourceGroup
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the logic app, that you want to work against

```yaml
Type: String
Parameter Sets: Subscription, ResourceGroup, NameOnly
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Task
List of task that you want to have executed, based on the runbook file that you pass

This allows you to only run a small subset of all the tasks that you have defined inside your runbook

Helpful when troubleshooting and trying to identify the best execution order of all the tasks

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkPath
Path to were the tasks will persist their outputs

Each task will save a file into a unique folder, containing the formatted output from its operation

You could risk that secrets or credentials are being stored on your disk, if they in some way are stored as clear text inside the logic app

The default valus is the current users TempPath, where it creates a "\PsLogicAppExtractor\GUID\" directory for each invoke

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: "$([System.IO.Path]::GetTempPath())PsLogicAppExtractor\$([System.Guid]::NewGuid().Guid)"
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Path to were the ARM template file will be persisted

The path has to be a directory

The file will be named as the Logic App is named

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeepFiles
Instruct the cmdlet to keep all the files, across all tasks

This enables troubleshooting and comparison of input vs output, per task, as each task has an input file and the result of the work persisted in the same directory

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

### -Tools
Instruct the cmdlet which tool to use

Options are:
AzCli (azure cli)
Az.Powershell (Az.Accounts+ PowerShell native modules)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Az.Powershell
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
