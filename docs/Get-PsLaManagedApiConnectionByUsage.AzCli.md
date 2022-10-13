---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaManagedApiConnectionByUsage.AzCli

## SYNOPSIS
Get Managed Api Connection objects by their usage

## SYNTAX

### ResourceGroup (Default)
```
Get-PsLaManagedApiConnectionByUsage.AzCli -ResourceGroup <String> [-IncludeUsed]
 [-IncludeLogicAppResourceNotFound] [<CommonParameters>]
```

### Subscription
```
Get-PsLaManagedApiConnectionByUsage.AzCli -SubscriptionId <String> -ResourceGroup <String> [-IncludeUsed]
 [-IncludeLogicAppResourceNotFound] [<CommonParameters>]
```

## DESCRIPTION
Get Managed Api Connection objects, and filter by their usage

You can list Api Connections that are NOT referenced by any Logic App
You can list Logic Apps and the Api Connections they reference, but doesn't exists
You can list Api Connections that are referenced by Logic Apps

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaManagedApiConnectionByUsage.AzCli -SubscriptionId "b466443d-6eac-4513-a7f0-3579502929f00" -ResourceGroup "TestRg"
```

This will list all Api Connections in the resource group "TestRg" in the subscription "b466443d-6eac-4513-a7f0-3579502929f00".
It will only list Api Connections that are NOT referenced by any Logic App

### EXAMPLE 2
```
Get-PsLaManagedApiConnectionByUsage.AzCli -SubscriptionId "b466443d-6eac-4513-a7f0-3579502929f00" -ResourceGroup "TestRg" -IncludeUsed
```

This will list all Api Connections in the resource group "TestRg" in the subscription "b466443d-6eac-4513-a7f0-3579502929f00".
It will list Api Connections that are NOT referenced by any Logic App.
It will list Api Connections that are referenced by Logic Apps.

### EXAMPLE 3
```
Get-PsLaManagedApiConnectionByUsage.AzCli -SubscriptionId "b466443d-6eac-4513-a7f0-3579502929f00" -ResourceGroup "TestRg" -IncludeLogicAppResourceNotFound
```

This will list all Api Connections in the resource group "TestRg" in the subscription "b466443d-6eac-4513-a7f0-3579502929f00".
It will list Api Connections that are NOT referenced by any Logic App.
It will list Api Connections that are referenced by Logic Apps, but where the Api Connection doesn't exists.

## PARAMETERS

### -SubscriptionId
Id of the subscription that you want to work against, your current az cli session either needs to be "connected" to the subscription or at least have permissions to work against the subscription

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
Name of the resource group that you want to work against, your current az cli session needs to have permissions to work against the resource group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeUsed
Instruct the cmdlet to include Api Connections that are referenced by Logic Apps

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

### -IncludeLogicAppResourceNotFound
Instructions the cmdlet to include Api Connections that are referenced by Logic Apps, but where the Api Connection doesn't exists

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

The implementation was inspired by the following blog post:
https://techcommunity.microsoft.com/t5/integrations-on-azure-blog/use-powershell-script-to-manage-your-api-connection-of-logic-app/ba-p/2668253
https://www.integration-playbook.io/docs/find-orphaned-api-connectors
https://github.com/sandroasp/Azure-Learning-Path/blob/main/Logic-Apps/Find-Azure-Orphaned-API-Connectors-powershell/Find-Orphaned-API-Connectors.ps1

## RELATED LINKS
