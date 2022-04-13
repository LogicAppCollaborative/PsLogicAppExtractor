---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaTask

## SYNOPSIS
Get tasks that are part of the module

## SYNTAX

```
Get-PsLaTask [[-Category] <String>] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
List all avaiable tasks that are part of the module, to be used for exporting, sanitizing and converting a LogicApp into a deployable ARM template

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaTask
```

List all available tasks

Output example:

Category   Name                                                  Description
--------   ----                                                  -----------
Arm        Set-Arm.Connections.ManagedApis.AsParameter           Loops all $connections childs…
Arm        Set-Arm.Connections.ManagedApis.AsVariable            Loops all $connections childs…
Arm        Set-Arm.Connections.ManagedApis.IdFormatted           Loops all $connections childs…
Arm        Set-Arm.IntegrationAccount.IdFormatted.Simple.AsParameter.AsVariable     Creates an Arm variable: integrationAccount…

### EXAMPLE 2
```
Get-PsLaTask -Category Converter
```

List all available tasks, which are in the Converter category

Output example:

Category  Name                     Description
--------  ----                     -----------
Converter ConvertTo-Arm            Converts the LogicApp json structure into a valid ARM template json
Converter ConvertTo-Raw Converts the raw LogicApp json structure into the a valid LogicApp json,…

### EXAMPLE 3
```
Get-PsLaTask -Detailed
```

List all available tasks, and outputs it in the detailed view

Output example:

Category    : Arm
Name        : Set-Arm.Connections.ManagedApis.AsParameter
Description : Loops all $connections childs
-Creates an Arm parameter, with prefix & suffix
--Sets the default value to the original name, extracted from connectionId property
-Sets the connectionId to: \[resourceId('Microsoft.Web/connections', parameters('XYZ'))\]
-Sets the connectionName to: \[parameters('XYZ')\]

Category    : Arm
Name        : Set-Arm.Connections.ManagedApis.AsVariable
Description : Loops all $connections childs
-Creates an Arm variable, with prefix & suffix
--Sets the value to the original name, extracted from connectionId property
-Sets the connectionId to: \[resourceId('Microsoft.Web/connections', variables('XYZ'))\]
-Sets the connectionName to: \[variables('XYZ')\]

## PARAMETERS

### -Category
Used to filter the number of tasks down to only being part of the category that you are looking for

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
