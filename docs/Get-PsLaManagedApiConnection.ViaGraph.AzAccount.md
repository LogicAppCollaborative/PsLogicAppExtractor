---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaManagedApiConnection.ViaGraph.AzAccount

## SYNOPSIS
Get ManagedApi connection objects

## SYNTAX

```
Get-PsLaManagedApiConnection.ViaGraph.AzAccount [[-SubscriptionId] <String>] [-ResourceGroup] <String>
 [-Summarized] [<CommonParameters>]
```

## DESCRIPTION
Get the ApiConnection objects from a resource group

Helps to identity ApiConnection objects that are orphaned, or which LogicApps is actually using the specific ApiConnection

Uses the current connected Az.Account session to pull the details from the azure portal

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaManagedApiConnection.ViaGraph.AzAccount -ResourceGroup "TestRg"
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group

Output example:

Name                                     ResourceGroup             IsReferenced LogicApp
----                                     -------------             ------------ --------
API-AzureBlob-ManagedIdentity            TestRg                            true LA-TestExport

### EXAMPLE 2
```
Get-PsLaManagedApiConnection.ViaGraph.AzAccount -ResourceGroup "TestRg" -Summarized
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
It will summarize how many LogicApps that is actually using the specific Api Connection

Output example:

Name                                     ResourceGroup             References SubscriptionId
----                                     -------------             ---------- --------------
API-AzureBlob-ManagedIdentity            TestRg                             1 b466443d-6eac-4513-a7f0-35795…

## PARAMETERS

### -SubscriptionId
Id of the subscription that you want to work against, your current Az.Account powershell session either needs to be "connected" to the subscription or at least have permissions to work against the subscription

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

### -ResourceGroup
Name of the resource group that you want to work against, your current powershell session needs to have permissions to work against the resource group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Summarized
Instruct the cmdlet to output a summarized References column

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
