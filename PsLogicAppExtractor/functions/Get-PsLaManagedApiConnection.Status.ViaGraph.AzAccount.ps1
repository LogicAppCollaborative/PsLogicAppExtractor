<#
#>
function Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [CmdletBinding()]
    param (
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup,

        [switch] $IncludeProperties,

        [ValidateSet('Unauthenticated', 'ConfigurationNeeded')]
        [string] $FilterError
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

    $query = Get-Content "$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Queries)\AzureResourceGraph.ApiConnections.Status.txt" -Raw

    $query = $query.Replace('##FILTERS##', $filter)

    if ($IncludeProperties) {
        $query = $query + ", Props"
    }

    $res = (Search-AzGraph -Query $query -First 1000)
    
    if ($FilterError) {
        $res = @(

            foreach ($item in $res) {
                if ($item.StatusDetails.error.code -contains $FilterError) {
                    $item
                }
            }
        )
    }

    $res = $res | Select-Object -Property *,
    @{Label = "StatusDetailed"; Expression = {
            $($_.StatusDetails | ConvertTo-Json -Depth 4).Replace("`r`n", "").Replace("  ", "")
        }
    } -ExcludeProperty StatusDetails

    if ($IncludeProperties) {
        $res | Select-PSFObject -Property *, "Props as PropertiesRaw" -TypeName PsLaExtractor.ManagedConnection.Graph.Status -ExcludeProperty Props
    }
    else {
        $res | Select-PSFObject -Property * -TypeName PsLaExtractor.ManagedConnection.Graph.Status
    }
}