
<#
    .SYNOPSIS
        Get ManagedApi connection objects
        
    .DESCRIPTION
        Get the ApiConnection objects from a resource group
        
        Helps to identity ApiConnection objects that are failed or missing an consent / authentication
        
    .PARAMETER SubscriptionId
        Id of the subscription that you want to work against, your current powershell / az cli session either needs to "connected" to the subscription or at least have permissions to work against the subscription
        
    .PARAMETER ResourceGroup
        Name of the resource group that you want to work against, your current powershell / az cli session needs to have permissions to work against the resource group
        
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
        PS C:\> Get-PsLaManagedApiConnection.AzAccount -ResourceGroup "TestRg"

        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        
        Output example:

        Name             DisplayName      OverallStatus Id                   StatusDetails
        ----             -----------      ------------- --                   -------------
        azureblob        TestFtpDownload  Connected     /subscriptions/467c… {"status": "Connect…
        azureeventgrid   TestEventGrid    Error         /subscriptions/467c… {"status": "Error",…
        azurequeues      Test             Connected     /subscriptions/467c… {"status": "Connect…

    .NOTES
        
    Author: Mötz Jensen (@Splaxi)
    
#>
function Get-PsLaManagedApiConnection.AzAccount {
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
    
    $parms = @{}
    $parms.ResourceGroupName = $ResourceGroup
    $parms.ApiVersion = "2018-07-01-preview"
    $parms.ResourceProviderName = "Microsoft.Web"
    $parms.ResourceType = "connections"

    if ($SubscriptionId) {
        $parms.SubscriptionId = $SubscriptionId
    }

    $res = Invoke-AzRestMethod -Method Get @parms

    $cons = $res.Content | ConvertFrom-Json -Depth 20 | Select-Object -ExpandProperty Value

    $temp = $cons | Select-PSFObject -TypeName PsLaExtractor.ManagedConnection -Property id, Name,
    @{Label = "DisplayName"; Expression = { $_.properties.DisplayName } },
    @{Label = "OverallStatus"; Expression = { $_.properties.overallStatus } },
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