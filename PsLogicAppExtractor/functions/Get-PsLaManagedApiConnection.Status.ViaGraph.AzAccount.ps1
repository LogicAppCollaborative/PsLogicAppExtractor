
<#
    .SYNOPSIS
        Get ManagedApi connection objects status
        
    .DESCRIPTION
        Get the status of ApiConnection objects from a resource group
        
        Helps to identity ApiConnection objects that are failed or missing an consent / authentication
        
        Uses the current connected Az.Account session to pull the details from the azure portal
        
    .PARAMETER SubscriptionId
        Id of the subscription that you want to work against, your current Az.Account powershell session either needs to be "connected" to the subscription or at least have permissions to work against the subscription
        
    .PARAMETER ResourceGroup
        Name of the resource group that you want to work against, your current powershell session needs to have permissions to work against the resource group
        
    .PARAMETER IncludeProperties
        Filter the list of ApiConnections to a specific (overall) status
        
    .PARAMETER FilterError
        Filter the list of ApiConnections to a specific error status
        
        Valid list of options:
        'Unauthenticated'
        'ConfigurationNeeded'
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount -ResourceGroup "TestRg"
        
        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        
        Output example:
        
        Name                                     State      Status     ApiType         AuthenticatedUser
        ----                                     -----      ------     -------         -----------------
        API-AzureBlob-ManagedIdentity            Enabled    Ready      azureblob
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount -ResourceGroup "TestRg" -FilterError "Unauthenticated"
        
        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        Will filter the list down to only show those which are "Unauthenticated"
        
        Output example:
        
        Name                                     State      Status               ApiType         AuthenticatedUser
        ----                                     -----      ------               -------         -----------------
        API-AzureBlob-ManagedIdentity            Error      Unauthenticated      azureblob
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.Status.ViaGraph.AzAccount -ResourceGroup "TestRg" -IncludeProperties | Format-List
        
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
        connectionState=Enabled; overallStatus=Ready; testRequests=System.Object[];
        testLinks=System.Object[]; statuses=System.Object[]; parameterValueSet=; api=}
        
    .NOTES
        
        Author: Mötz Jensen (@Splaxi)
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