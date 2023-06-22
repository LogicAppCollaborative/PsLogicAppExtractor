<#
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