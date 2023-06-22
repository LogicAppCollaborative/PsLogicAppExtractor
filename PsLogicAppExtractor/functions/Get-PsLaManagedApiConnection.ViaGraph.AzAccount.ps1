
<#
    .SYNOPSIS
        Get ManagedApi connection objects
        
    .DESCRIPTION
        Get the ApiConnection objects from a resource group
        
        Helps to identity ApiConnection objects that are orphaned, or which LogicApps is actually using the specific ApiConnection
        
        Uses the current connected Az.Account session to pull the details from the azure portal
        
    .PARAMETER SubscriptionId
        Id of the subscription that you want to work against, your current Az.Account powershell session either needs to be "connected" to the subscription or at least have permissions to work against the subscription
        
    .PARAMETER ResourceGroup
        Name of the resource group that you want to work against, your current powershell session needs to have permissions to work against the resource group
        
    .PARAMETER Summarized
        Instruct the cmdlet to output a summarized References column
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.ViaGraph.AzAccount -ResourceGroup "TestRg"
        
        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        
        Output example:
        
        Name                                     ResourceGroup             IsReferenced LogicApp
        ----                                     -------------             ------------ --------
        API-AzureBlob-ManagedIdentity            TestRg                            true LA-TestExport
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.ViaGraph.AzAccount -ResourceGroup "TestRg" -Summarized
        
        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        It will summarize how many LogicApps that is actually using the specific Api Connection
        
        Output example:
        
        Name                                     ResourceGroup             References SubscriptionId
        ----                                     -------------             ---------- --------------
        API-AzureBlob-ManagedIdentity            TestRg                             1 b466443d-6eac-4513-a7f0-35795…
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-PsLaManagedApiConnection.ViaGraph.AzAccount {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [CmdletBinding()]
    param (
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup,

        [switch] $Summarized
    )

    if (-not $SubscriptionId) {
        $SubscriptionId = (Get-AzContext).Subscription.Id
    }
    
    $SubscriptionId = $SubscriptionId.ToLower()

    $filter = ''

    if ($SubscriptionId) {
        $filter += " and subscriptionId == '$SubscriptionId'"
    }

    $filter += " and resourceGroup =~ '$ResourceGroup'"

    if ($Summarized) {
        $query = Get-Content "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Queries)\AzureResourceGraph.ApiConnections.Summarized.txt" -Raw

        $query = $query.Replace('##FILTERS##', $filter)

        (Search-AzGraph -Query $query) | Select-PSFObject -Property *, "LogicAppReferences as References" -TypeName PsLaExtractor.ManagedConnection.Graph.Summarized -ExcludeProperty LogicAppReferences
    }
    else {
        $query = Get-Content "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Queries)\AzureResourceGraph.ApiConnections.Detailed.txt" -Raw

        $query = $query.Replace('##FILTERS##', $filter)

        (Search-AzGraph -Query $query) | Select-PSFObject -Property *, "IsLogicAppReferenced as IsReferenced" -TypeName PsLaExtractor.ManagedConnection.Graph.Base -ExcludeProperty IsLogicAppReferenced
    }

    return
}