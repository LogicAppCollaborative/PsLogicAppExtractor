---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount

## SYNOPSIS
Get ManagedApi connection objects status

## SYNTAX

```
Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount [[-SubscriptionId] <String>] [-ResourceGroup] <String>
 [-IncludeProperties] [[-FilterError] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the status of ApiConnection objects from a resource group

Helps to identity ApiConnection objects that are failed or missing an consent / authentication

Uses the current connected Az.Account session to pull the details from the azure portal

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount -ResourceGroup "TestRg"
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group

Output example:

Name                                     State      Status     ApiType         AuthenticatedUser
----                                     -----      ------     -------         -----------------
API-AzureBlob-ManagedIdentity            Enabled    Ready      azureblob

### EXAMPLE 2
```
Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount -ResourceGroup "TestRg" -FilterError "Unauthenticated"
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
Will filter the list down to only show those which are "Unauthenticated"

Output example:

Name                                     State      Status               ApiType         AuthenticatedUser
----                                     -----      ------               -------         -----------------
API-AzureBlob-ManagedIdentity            Error      Unauthenticated      azureblob

### EXAMPLE 3
```
Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount -ResourceGroup "TestRg" -IncludeProperties | Format-List
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
Will extract the raw properties of the ApiConnection object, and expose them in the output
Format-List is needed to display the PropertiesRaw on screen

Output example:

Id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg
/providers/Microsoft.Web/connections/API-AzureBlob-ManagedIdentity
Name              : API-AzureBlob-ManagedIdentity
ResourceGroup     : TestRg
SubscriptionId    : b466443d-6eac-4513-a7f0-3579502929f00
DisplayName       : API-AzureBlob-ManagedIdentity
State             : Enabled
Status            : Ready
ApiType           : azureblob
AuthenticatedUser :
ParameterValues   :
StatusDetailed    : {"status": "Ready"}
PropertiesRaw     : @{displayName=API-AzureBlob-ManagedIdentity; createdTime=22/06/2023 07.07.22;
changedTime=22/06/2023 07.07.22; customParameterValues=; authenticatedUser=;
connectionState=Enabled; overallStatus=Ready; testRequests=System.Object\[\];
testLinks=System.Object\[\]; statuses=System.Object\[\]; parameterValueSet=; api=}

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

### -IncludeProperties
Filter the list of ApiConnections to a specific (overall) status

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

### -FilterError
Filter the list of ApiConnections to a specific error status

Valid list of options:
'Unauthenticated'
'ConfigurationNeeded'

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Mötz Jensen (@Splaxi)

## RELATED LINKS
