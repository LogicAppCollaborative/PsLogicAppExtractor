---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaManagedApiConnection.AzAccount

## SYNOPSIS
Get ManagedApi connection objects

## SYNTAX

### ResourceGroup (Default)
```
Get-PsLaManagedApiConnection.AzAccount -ResourceGroup <String> [-FilterError <String>]
 [-IncludeStatus <String>] [-Detailed] [<CommonParameters>]
```

### Subscription
```
Get-PsLaManagedApiConnection.AzAccount -SubscriptionId <String> -ResourceGroup <String> [-FilterError <String>]
 [-IncludeStatus <String>] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
Get the ApiConnection objects from a resource group

Helps to identity ApiConnection objects that are failed or missing an consent / authentication

## EXAMPLES

### EXAMPLE 1
```
An example
```

## PARAMETERS

### -SubscriptionId
Id of the subscription that you want to work against, your current powershell / az cli session either needs to "connected" to the subscription or at least have permissions to work against the subscription

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
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterError
Filter the list of ApiConnections to a specific error status

Valid list of options:
'Unauthorized'
'Unauthenticated'

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

### -IncludeStatus
Filter the list of ApiConnections to a specific (overall) status

Valid list of options:
Connected
Error

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

### -Detailed
Instruct the cmdlet to output with the detailed format directly

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
General notes

## RELATED LINKS
