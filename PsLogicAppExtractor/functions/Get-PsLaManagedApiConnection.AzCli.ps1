
<#
    .SYNOPSIS
        Get ManagedApi connection objects
        
    .DESCRIPTION
        Get the ApiConnection objects from a resource group
        
        Helps to identity ApiConnection objects that are failed or missing an consent / authentication

        Uses the current connected az cli session to pull the details from the azure portal
        
    .PARAMETER SubscriptionId
        Id of the subscription that you want to work against, your current az cli session either needs to be "connected" to the subscription or at least have permissions to work against the subscription
        
    .PARAMETER ResourceGroup
        Name of the resource group that you want to work against, your current az cli session needs to have permissions to work against the resource group
        
    .PARAMETER FilterError
        Filter the list of ApiConnections to a specific error status
        
        Valid list of options:
        'Unauthorized'
        'Unauthenticated'
        
    .PARAMETER IncludeStatus
        Filter the list of ApiConnections to a specific (overall) status
        
        Valid list of options:
        Connected
        Error
        
    .PARAMETER Detailed
        Instruct the cmdlet to output with the detailed format directly
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg"
        
        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        
        Output example:
        
        Name             DisplayName      OverallStatus Id                   StatusDetails
        ----             -----------      ------------- --                   -------------
        azureblob        TestFtpDownload  Connected     /subscriptions/467c… {"status": "Connect…
        azureeventgrid   TestEventGrid    Error         /subscriptions/467c… {"status": "Error",…
        azurequeues      Test             Connected     /subscriptions/467c… {"status": "Connect…
        office365        MyPersonalCon..  Connected     /subscriptions/467c… {"status": "Error",…
        office365-1      MyPersonalCon..  Connected     /subscriptions/467c… {"status": "Connect…
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -Detailed

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
                                    "message": "Failed to refresh access token for service: aadcertificate. Correlation
                                Id=g-3bdeeea8-ae1f-4ac3-82dc-7fee7f16a1e2, UTC TimeStamp=4/8/2021 11:40:36 PM, Error: Failed to
                                acquire token from AAD: {\"error\":\"invalid_grant\",\"error_description\":\"AADSTS700082: The refresh
                                token has expired due to inactivity.The token was issued on 2020-09-01T12:13:41.5336734Z and was
                                inactive for 90.00:00:00.\\r\\nTrace ID: b6f03183-79e9-4f81-a640-efcf65c30400\\r\\nCorrelation ID:
                                52b391c3-9c1d-42c7-99f3-a219b7675aee\\r\\nTimestamp: 2021-04-08
                                23:40:36Z\",\"error_codes\":[700082],\"timestamp\":\"2021-04-08 23:40:36Z\",\"trace_id\":\"b6f03183-79e
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

        .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -IncludeStatus Error -Detailed
        
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
                                    "message": "Failed to refresh access token for service: aadcertificate. Correlation
                                Id=g-3bdeeea8-ae1f-4ac3-82dc-7fee7f16a1e2, UTC TimeStamp=4/8/2021 11:40:36 PM, Error: Failed to
                                acquire token from AAD: {\"error\":\"invalid_grant\",\"error_description\":\"AADSTS700082: The refresh
                                token has expired due to inactivity.The token was issued on 2020-09-01T12:13:41.5336734Z and was
                                inactive for 90.00:00:00.\\r\\nTrace ID: b6f03183-79e9-4f81-a640-efcf65c30400\\r\\nCorrelation ID:
                                52b391c3-9c1d-42c7-99f3-a219b7675aee\\r\\nTimestamp: 2021-04-08
                                23:40:36Z\",\"error_codes\":[700082],\"timestamp\":\"2021-04-08 23:40:36Z\",\"trace_id\":\"b6f03183-79e
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

        .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthenticated -Detailed
        
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

        .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthorized -Detailed
        
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
                                    "message": "Failed to refresh access token for service: aadcertificate. Correlation
                                Id=g-3bdeeea8-ae1f-4ac3-82dc-7fee7f16a1e2, UTC TimeStamp=4/8/2021 11:40:36 PM, Error: Failed to
                                acquire token from AAD: {\"error\":\"invalid_grant\",\"error_description\":\"AADSTS700082: The refresh
                                token has expired due to inactivity.The token was issued on 2020-09-01T12:13:41.5336734Z and was
                                inactive for 90.00:00:00.\\r\\nTrace ID: b6f03183-79e9-4f81-a640-efcf65c30400\\r\\nCorrelation ID:
                                52b391c3-9c1d-42c7-99f3-a219b7675aee\\r\\nTimestamp: 2021-04-08
                                23:40:36Z\",\"error_codes\":[700082],\"timestamp\":\"2021-04-08 23:40:36Z\",\"trace_id\":\"b6f03183-79e
                                9-4f81-a640-efcf65c30400\",\"correlation_id\":\"52b391c3-9c1d-42c7-99f3-a219b7675aee\",\"error_uri\":\"
                                https://login.windows.net/error?code=700082\"}"
                                }
                            }

        .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthenticated | Invoke-PsLaConsent.AzCli
        
        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        Filters the list to show only the ones with error of the type Unauthenticated
        Will pipe the objects to Invoke-PsLaConsent.AzCli, which will prompt you to enter a valid user account / credentials
        
        Note: Read more about Invoke-PsLaConsent.AzCli before running this command, to ensure you understand what it does

    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-PsLaManagedApiConnection.AzCli {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPositionalParameters', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [CmdletBinding(DefaultParameterSetName = "ResourceGroup")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $ResourceGroup,

        [ValidateSet('Unauthorized', 'Unauthenticated')]
        [string] $FilterError,

        [ValidateSet('Connected', 'Error')]
        [string] $IncludeStatus,

        [switch] $Detailed
    )
    
    $uri = "/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroup/providers/Microsoft.Web/connections?api-version=2018-07-01-preview"

    if ($SubscriptionId) {
        $uri = $uri.Replace("{subscriptionId}", $SubscriptionId)
    }

    $res = az rest --url "$uri" | ConvertFrom-Json -Depth 10
    
    if ($null -eq $res) {
        #TODO! We need to throw an error
        Throw
    }

    $cons = $res | Select-Object -ExpandProperty Value

    $temp = $cons | Select-PSFObject -TypeName PsLaExtractor.ManagedConnection -Property id, Name,
    @{Label = "DisplayName"; Expression = { $_.properties.DisplayName } },
    @{Label = "OverallStatus"; Expression = { $_.properties.overallStatus } },
    @{Label = "AuthenticatedUser"; Expression = { $_.properties.authenticatedUser } },
    @{Label = "ParameterValues"; Expression = { $_.properties.parameterValues } },
    @{Label = "StatusDetails"; Expression = {
            if ($Detailed) {
                $_.properties.Statuses | ConvertTo-Json -Depth 4
            }
            else {
                $($_.properties.Statuses | ConvertTo-Json -Depth 4).Replace("`r`n", "").Replace("  ", "")
            }
        }
    }

    if ($FilterError -or $IncludeStatus) {
        $filtered = @(foreach ($item in $temp) {
                $details = $item.StatusDetails | ConvertFrom-Json -Depth 10

                if ($FilterError -and $details.error.code -ne $FilterError) {
                    continue
                }

                if ($IncludeStatus -and $item.OverallStatus -ne $IncludeStatus) {
                    continue
                }

                $item
            }
        )

        $temp = $filtered
    }

    if ($Detailed) {
        $temp | Select-PSFObject -Property * -TypeName PsLaExtractor.ManagedConnection.Detailed
    }
    else {
        $temp
    }
}