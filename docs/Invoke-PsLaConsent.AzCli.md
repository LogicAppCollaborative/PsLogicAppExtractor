---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Invoke-PsLaConsent.AzCli

## SYNOPSIS
Start the consent flow for an ApiConnection object

## SYNTAX

```
Invoke-PsLaConsent.AzCli [-Id] <String> [<CommonParameters>]
```

## DESCRIPTION
Some of the ApiConnection objects needs an user account to consent / authenticate, before it works

This cmdlet helps starting, running and completing the consent flow an ApiConnection object

Uses the current connected az cli session to pull the details from the azure portal

## EXAMPLES

### EXAMPLE 1
```
Invoke-PsLaConsent.AzCli -Id "/subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/providers/Microsoft.Web/locations/westeurope/managedApis/servicebus"
```

This will start the consent flow for the ApiConnection object
It will prompt the user to fill in an account / credential
It will confirm the consent directly to the ApiConnection object

### EXAMPLE 2
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthenticated | Invoke-PsLaConsent.AzCli
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
Filters the list to show only the ones with error of the type Unauthenticated
Will pipe the objects to Invoke-PsLaConsent.AzCli
This will start the consent flow for the ApiConnection object
It will prompt the user to fill in an account / credential
It will confirm the consent directly to the ApiConnection object

## PARAMETERS

### -Id
The (resource) id of the ApiConnection object that you want to work against, your current az cli session either needs to be "connected" to the subscription/resource group or at least have permissions to work against the subscription/resource group, where the ApiConnection object is located

```yaml
Type: String
Parameter Sets: (All)
Aliases: ResourceId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This is highly inspired by the previous work of other smart people:
https://github.com/logicappsio/LogicAppConnectionAuth/blob/master/LogicAppConnectionAuth.ps1
https://github.com/OfficeDev/microsoft-teams-apps-requestateam/blob/master/Deployment/Scripts/deploy.ps1

Author: Mötz Jensen (@Splaxi)

## RELATED LINKS
