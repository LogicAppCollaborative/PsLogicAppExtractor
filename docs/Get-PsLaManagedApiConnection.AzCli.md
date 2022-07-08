---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-PsLaManagedApiConnection.AzCli

## SYNOPSIS
Get ManagedApi connection objects

## SYNTAX

### ResourceGroup (Default)
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup <String> [-FilterError <String>] [-IncludeStatus <String>]
 [-Detailed] [<CommonParameters>]
```

### Subscription
```
Get-PsLaManagedApiConnection.AzCli -SubscriptionId <String> -ResourceGroup <String> [-FilterError <String>]
 [-IncludeStatus <String>] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
Get the ApiConnection objects from a resource group

Helps to identity ApiConnection objects that are failed or missing an consent / authentication

Uses the current connected az cli session to pull the details from the azure portal

## EXAMPLES

### EXAMPLE 1
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg"
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group

Output example:

Name             DisplayName      OverallStatus Id                   StatusDetails
----             -----------      ------------- --                   -------------
azureblob        TestFtpDownload  Connected     /subscriptions/467c… {"status": "Connect…
azureeventgrid   TestEventGrid    Error         /subscriptions/467c… {"status": "Error",…
azurequeues      Test             Connected     /subscriptions/467c… {"status": "Connect…
office365        MyPersonalCon.. 
Connected     /subscriptions/467c… {"status": "Error",…
office365-1      MyPersonalCon.. 
Connected     /subscriptions/467c… {"status": "Connect…

### EXAMPLE 2
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -Detailed
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
It will display detailed information about the ApiConnection object
Output example:

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    eb/connections/azureblob
name              : azureblob
DisplayName       : TestFtpDownload
AuthenticatedUser :
ParameterValues   : @{accountName=storageaccount1}
OverallStatus     : Connected
StatusDetails     : {
                    "status": "Connected"
                    }

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    eb/connections/azureeventgrid
name              : azureeventgrid
DisplayName       : TestEventGrid
AuthenticatedUser : @{name=sarah@contoso.com}
ParameterValues   : @{token:TenantId=f312ba7d-b63a-4306-9e97-a623c3f42024; token:grantType=code}
OverallStatus     : Error
StatusDetails     : {
                        "status": "Error",
                        "target": "token",
                        "error": {
                            "code": "Unauthorized",
                            "message": "Failed to refresh access token for service: aadcertificate.
Correlation
                        Id=g-3bdeeea8-ae1f-4ac3-82dc-7fee7f16a1e2, UTC TimeStamp=4/8/2021 11:40:36 PM, Error: Failed to
                        acquire token from AAD: {\"error\":\"invalid_grant\",\"error_description\":\"AADSTS700082: The refresh
                        token has expired due to inactivity.The token was issued on 2020-09-01T12:13:41.5336734Z and was
                        inactive for 90.00:00:00.\\\\r\\\\nTrace ID: b6f03183-79e9-4f81-a640-efcf65c30400\\\\r\\\\nCorrelation ID:
                        52b391c3-9c1d-42c7-99f3-a219b7675aee\\\\r\\\\nTimestamp: 2021-04-08
                        23:40:36Z\",\"error_codes\":\[700082\],\"timestamp\":\"2021-04-08 23:40:36Z\",\"trace_id\":\"b6f03183-79e
                        9-4f81-a640-efcf65c30400\",\"correlation_id\":\"52b391c3-9c1d-42c7-99f3-a219b7675aee\",\"error_uri\":\"
                        https://login.windows.net/error?code=700082\"}"
                        }
                    }

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    eb/connections/office365
name              : office365
DisplayName       : MyPersonalConnection
AuthenticatedUser :
ParameterValues   :
OverallStatus     : Error
StatusDetails     : {
                        "status": "Error",
                        "target": "token",
                        "error": {
                            "code": "Unauthenticated",
                            "message": "This connection is not authenticated."
                        }
                    }

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    ft.Web/connections/office365-1
name              : office365-1
DisplayName       : MyPersonalConnection2
AuthenticatedUser : @{name=sarah@contoso.com}
ParameterValues   :
OverallStatus     : Connected
StatusDetails     : {
                        "status": "Connected"
                    }

### EXAMPLE 3
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -IncludeStatus Error -Detailed
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
Filters the list to show only the ones with error

Output example:

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    eb/connections/azureeventgrid
name              : azureeventgrid
DisplayName       : TestEventGrid
AuthenticatedUser : @{name=sarah@contoso.com}
ParameterValues   : @{token:TenantId=f312ba7d-b63a-4306-9e97-a623c3f42024; token:grantType=code}
OverallStatus     : Error
StatusDetails     : {
                        "status": "Error",
                        "target": "token",
                        "error": {
                            "code": "Unauthorized",
                            "message": "Failed to refresh access token for service: aadcertificate.
Correlation
                        Id=g-3bdeeea8-ae1f-4ac3-82dc-7fee7f16a1e2, UTC TimeStamp=4/8/2021 11:40:36 PM, Error: Failed to
                        acquire token from AAD: {\"error\":\"invalid_grant\",\"error_description\":\"AADSTS700082: The refresh
                        token has expired due to inactivity.The token was issued on 2020-09-01T12:13:41.5336734Z and was
                        inactive for 90.00:00:00.\\\\r\\\\nTrace ID: b6f03183-79e9-4f81-a640-efcf65c30400\\\\r\\\\nCorrelation ID:
                        52b391c3-9c1d-42c7-99f3-a219b7675aee\\\\r\\\\nTimestamp: 2021-04-08
                        23:40:36Z\",\"error_codes\":\[700082\],\"timestamp\":\"2021-04-08 23:40:36Z\",\"trace_id\":\"b6f03183-79e
                        9-4f81-a640-efcf65c30400\",\"correlation_id\":\"52b391c3-9c1d-42c7-99f3-a219b7675aee\",\"error_uri\":\"
                        https://login.windows.net/error?code=700082\"}"
                        }
                    }

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    eb/connections/office365
name              : office365
DisplayName       : MyPersonalConnection
AuthenticatedUser :
ParameterValues   :
OverallStatus     : Error
StatusDetails     : {
                        "status": "Error",
                        "target": "token",
                        "error": {
                            "code": "Unauthenticated",
                            "message": "This connection is not authenticated."
                        }
                    }

### EXAMPLE 4
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthenticated -Detailed
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
Filters the list to show only the ones with error of the type Unauthenticated

This is useful in combination with the Invoke-PsLaConsent.AzCli cmdlet

Output example:

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    eb/connections/office365
name              : office365
DisplayName       : MyPersonalConnection
AuthenticatedUser :
ParameterValues   :
OverallStatus     : Error
StatusDetails     : {
                        "status": "Error",
                        "target": "token",
                        "error": {
                            "code": "Unauthenticated",
                            "message": "This connection is not authenticated."
                        }
                    }

### EXAMPLE 5
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthorized -Detailed
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
Filters the list to show only the ones with error of the type Unauthenticated

Output example:

id                : /subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/TestRg/providers/Microsoft.W
                    eb/connections/azureeventgrid
name              : azureeventgrid
DisplayName       : TestEventGrid
AuthenticatedUser : @{name=sarah@contoso.com}
ParameterValues   : @{token:TenantId=f312ba7d-b63a-4306-9e97-a623c3f42024; token:grantType=code}
OverallStatus     : Error
StatusDetails     : {
                        "status": "Error",
                        "target": "token",
                        "error": {
                            "code": "Unauthorized",
                            "message": "Failed to refresh access token for service: aadcertificate.
Correlation
                        Id=g-3bdeeea8-ae1f-4ac3-82dc-7fee7f16a1e2, UTC TimeStamp=4/8/2021 11:40:36 PM, Error: Failed to
                        acquire token from AAD: {\"error\":\"invalid_grant\",\"error_description\":\"AADSTS700082: The refresh
                        token has expired due to inactivity.The token was issued on 2020-09-01T12:13:41.5336734Z and was
                        inactive for 90.00:00:00.\\\\r\\\\nTrace ID: b6f03183-79e9-4f81-a640-efcf65c30400\\\\r\\\\nCorrelation ID:
                        52b391c3-9c1d-42c7-99f3-a219b7675aee\\\\r\\\\nTimestamp: 2021-04-08
                        23:40:36Z\",\"error_codes\":\[700082\],\"timestamp\":\"2021-04-08 23:40:36Z\",\"trace_id\":\"b6f03183-79e
                        9-4f81-a640-efcf65c30400\",\"correlation_id\":\"52b391c3-9c1d-42c7-99f3-a219b7675aee\",\"error_uri\":\"
                        https://login.windows.net/error?code=700082\"}"
                        }
                    }

### EXAMPLE 6
```
Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthenticated | Invoke-PsLaConsent.AzCli
```

This will fetch all ApiConnection objects from the "TestRg" Resource Group
Filters the list to show only the ones with error of the type Unauthenticated
Will pipe the objects to Invoke-PsLaConsent.AzCli, which will prompt you to enter a valid user account / credentials

Note: Read more about Invoke-PsLaConsent.AzCli before running this command, to ensure you understand what it does

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
Author: Mötz Jensen (@Splaxi)

## RELATED LINKS
