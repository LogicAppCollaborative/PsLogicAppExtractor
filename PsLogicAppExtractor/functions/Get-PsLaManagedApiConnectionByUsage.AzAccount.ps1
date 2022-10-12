<#
.SYNOPSIS
Get Managed Api Connection objects by their usage

.DESCRIPTION
Get Managed Api Connection objects, and filter by their usage

You can list Api Connections that are NOT referenced by any Logic App
You can list Logic Apps and the Api Connections they reference, but doesn't exists
You can list Api Connections that are referenced by Logic Apps

    .PARAMETER SubscriptionId
        Id of the subscription that you want to work against, your current az cli session either needs to be "connected" to the subscription or at least have permissions to work against the subscription
        
    .PARAMETER ResourceGroup
        Name of the resource group that you want to work against, your current az cli session needs to have permissions to work against the resource group

.PARAMETER IncludeUsed
Instruct the cmdlet to include Api Connections that are referenced by Logic Apps

.PARAMETER IncludeLogicAppResourceNotFound
Instructions the cmdlet to include Api Connections that are referenced by Logic Apps, but where the Api Connection doesn't exists

.EXAMPLE
PS C:\> Get-PsLaManagedApiConnectionByUsage.AzAccount -SubscriptionId "b466443d-6eac-4513-a7f0-3579502929f00" -ResourceGroup "TestRg"

This will list all Api Connections in the resource group "TestRg" in the subscription "b466443d-6eac-4513-a7f0-3579502929f00".
It will only list Api Connections that are NOT referenced by any Logic App

.EXAMPLE
PS C:\> Get-PsLaManagedApiConnectionByUsage.AzAccount -SubscriptionId "b466443d-6eac-4513-a7f0-3579502929f00" -ResourceGroup "TestRg" -IncludeUsed

This will list all Api Connections in the resource group "TestRg" in the subscription "b466443d-6eac-4513-a7f0-3579502929f00".
It will list Api Connections that are NOT referenced by any Logic App.
It will list Api Connections that are referenced by Logic Apps.

.EXAMPLE
PS C:\> Get-PsLaManagedApiConnectionByUsage.AzAccount -SubscriptionId "b466443d-6eac-4513-a7f0-3579502929f00" -ResourceGroup "TestRg" -IncludeLogicAppResourceNotFound

This will list all Api Connections in the resource group "TestRg" in the subscription "b466443d-6eac-4513-a7f0-3579502929f00".
It will list Api Connections that are NOT referenced by any Logic App.
It will list Api Connections that are referenced by Logic Apps, but where the Api Connection doesn't exists.

.NOTES
Author: Mötz Jensen (@Splaxi)

The implementation was inspired by the following blog post:
https://techcommunity.microsoft.com/t5/integrations-on-azure-blog/use-powershell-script-to-manage-your-api-connection-of-logic-app/ba-p/2668253
https://www.integration-playbook.io/docs/find-orphaned-api-connectors
https://github.com/sandroasp/Azure-Learning-Path/blob/main/Logic-Apps/Find-Azure-Orphaned-API-Connectors-powershell/Find-Orphaned-API-Connectors.ps1

#>
function Get-PsLaManagedApiConnectionByUsage.AzAccount {
    [CmdletBinding(DefaultParameterSetName = "ResourceGroup")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Subscription")]
        [string] $ResourceGroup,

        [switch] $IncludeUsed,

        [switch] $IncludeLogicAppResourceNotFound

    )
    
    # Uri for the Azure REST API, to get Api Connections and Logic Apps
    $uriConnetions = "/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroup/providers/Microsoft.Web/connections?api-version=2018-07-01-preview"
    $uriWorkflows = "/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroup/providers/Microsoft.Logic/workflows?api-version=2018-07-01-preview"

    if ($SubscriptionId) {
        $uriConnetions = $uriConnetions.Replace("{subscriptionId}", $SubscriptionId)
        $uriWorkflows = $uriWorkflows.Replace("{subscriptionId}", $SubscriptionId)
    }

    [System.Collections.Generic.List[System.Object]] $resArray = @()
    $localUri = $uriConnetions
    do {
        # Fething the Api Connections
        # The do while supports paging / nextLink to load all objects from the resource group
        $resGet = Invoke-AzRest -Path "$localUri" -Method GET | Select-Object -ExpandProperty Content | ConvertFrom-Json -Depth 100

        $resArray.AddRange($resGet.Value)
            
        if ($($resGet.nextLink) -match ".*(/subscriptions/.*)") {
            $localUri = $Matches[1]
        }

    } while ($resGet.nextLink)

    # Persist the Api Connections
    $resConnections = $resArray.ToArray()

    [System.Collections.Generic.List[System.Object]] $resArray = @()
    $localUri = $uriWorkflows
    do {
        # Fething the Logic Apps
        # The do while supports paging / nextLink to load all objects from the resource group
        $resLocal = Invoke-AzRest -Path "$localUri" -Method GET | Select-Object -ExpandProperty Content
           
        # Hack to handle any errors in the response, which cannot be handled by the ConvertFrom-Json
        $resGet = $resLocal.Replace('""', '"Dummy"') | ConvertFrom-Json -Depth 100
        $resArray.AddRange($resGet.Value)
            
        if ($($resGet.nextLink) -match ".*(/subscriptions/.*)") {
            $localUri = $Matches[1]
        }
        # } while (1 -eq 2)
    } while ($resGet.nextLink)

    # Persist the Logic Apps
    $resWorkflows = $resArray.ToArray()
    
    if ($null -eq $resConnections -or $null -eq $resWorkflows) {
        #TODO! We need to throw an error
        Throw
    }

    # Create an array of all Api Connections available
    $availableConnections = @($resConnections.id)

    [System.Collections.Generic.List[System.Object]] $colUsedConnections = @()
    [System.Collections.Generic.List[System.Object]] $colNonExistingConnections = @()

    # Loop through all Logic Apps
    foreach ($la in $resWorkflows) {

        # Not all Logic Apps have a connection reference
        if ($null -eq $la.properties.parameters.'$connections') { continue }
        
        # Loop through all connections of the Logic App
        foreach ($connection in $la.properties.parameters.'$connections'.value.PsObject.Properties) {

            if ($connection.value.connectionId -in $availableConnections) {
                # The connection was found in the available connections
                $colUsedConnections.Add(
                    [PSCustomObject]@{
                        Id         = $connection.value.connectionId
                        Connection = $resConnections | Where-Object { $_.id -eq $connection.value.connectionId } | Select-Object -First 1
                        LogicApp   = $la.Name
                    }
                )
            }
            else {
                # The connection was not found in the available connections
                $colNonExistingConnections.Add(
                    [PSCustomObject]@{
                        LogicApp          = $la.Name
                        ConnectionDetails = $connection
                    }
                )
            }
        }
    }

    [System.Collections.Generic.List[System.Object]] $resArray = @()
    
    if ($IncludeUsed -and $colUsedConnections.Count -gt 0) {
        # Should we add all used connections?
        $resArray.AddRange(
            ($colUsedConnections.ToArray() | Select-PSFObject -TypeName PsLaExtractor.ManagedConnection.Usage -Property Id,
            @{Label = "Name"; Expression = { $_.Connection.Name } },
            @{Label = "DisplayName"; Expression = { $_.Connection.Properties.DisplayName } },
            LogicApp,
            @{Label = "Usage"; Expression = { "LogicAppReferenced" } },
            @{Label = "Location"; Expression = { $_.Connection.Location } },
            @{Label = "Type"; Expression = { $_.Connection.Properties.Api.Name } },
            @{Label = "Properties"; Expression = { $_.Connection.Properties } })

        )
    }
    
    if ($IncludeLogicAppResourceNotFound -and $colUsedConnections.Count -gt 0) {
        # Should we add all connections, that Logic Apps are referencing, but are not available?
        $resArray.AddRange(
        ($colNonExistingConnections.ToArray() | Select-PSFObject -TypeName PsLaExtractor.ManagedConnection.Usage -Property @{Label = "Id"; Expression = { $_.ConnectionDetails.Value.connectionId } },
            @{Label = "Name"; Expression = { $_.ConnectionDetails.Name } },
            @{Label = "DisplayName"; Expression = { $_.ConnectionDetails.Value.connectionName } },
            LogicApp,
            @{Label = "Usage"; Expression = { "ResourceNotFound" } },
            @{Label = "Location"; Expression = { ($_.ConnectionDetails.Value.Id | Select-String -Pattern "/locations/(.*?)/").Matches[0].Groups[1].Value } },
            @{Label = "Type"; Expression = { $_.ConnectionDetails.Value.Id.Split("/") | Select-Object -Last 1 } })
        )
    }

    $resConnections | Where-Object { -not ($_.id -in $colUsedConnections.Id) } | Foreach-object {
        # Add all connections, that are not used by any Logic App
        $resArray.Add(
            [PSCustomObject]@{
                Id          = $_.id
                Name        = $_.name
                DisplayName = $_.properties.displayName
                LogicApp    = $null
                Usage       = "NotUsed"
                Location    = $_.location
                Type        = $_.properties.api.name
                Properties  = $_.properties
            }
        )
    }

    $resArray
}