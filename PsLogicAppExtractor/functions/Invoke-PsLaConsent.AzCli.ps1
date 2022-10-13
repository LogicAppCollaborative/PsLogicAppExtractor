
<#
    .SYNOPSIS
        Start the consent flow for an ApiConnection object
        
    .DESCRIPTION
        Some of the ApiConnection objects needs an user account to consent / authenticate, before it works
        
        This cmdlet helps starting, running and completing the consent flow an ApiConnection object
        
        Uses the current connected az cli session to pull the details from the azure portal
        
    .PARAMETER Id
        The (resource) id of the ApiConnection object that you want to work against, your current az cli session either needs to be "connected" to the subscription/resource group or at least have permissions to work against the subscription/resource group, where the ApiConnection object is located
        
    .EXAMPLE
        PS C:\> Invoke-PsLaConsent.AzCli -Id "/subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/providers/Microsoft.Web/locations/westeurope/managedApis/servicebus"
        
        This will start the consent flow for the ApiConnection object
        It will prompt the user to fill in an account / credential
        It will confirm the consent directly to the ApiConnection object
        
    .EXAMPLE
        PS C:\> Get-PsLaManagedApiConnection.AzCli -ResourceGroup "TestRg" -FilterError Unauthenticated | Invoke-PsLaConsent.AzCli
        
        This will fetch all ApiConnection objects from the "TestRg" Resource Group
        Filters the list to show only the ones with error of the type Unauthenticated
        Will pipe the objects to Invoke-PsLaConsent.AzCli
        This will start the consent flow for the ApiConnection object
        It will prompt the user to fill in an account / credential
        It will confirm the consent directly to the ApiConnection object
        
    .NOTES
        This is highly inspired by the previous work of other smart people:
        https://github.com/logicappsio/LogicAppConnectionAuth/blob/master/LogicAppConnectionAuth.ps1
        https://github.com/OfficeDev/microsoft-teams-apps-requestateam/blob/master/Deployment/Scripts/deploy.ps1
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Invoke-PsLaConsent.AzCli {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPositionalParameters', '')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("ResourceId")]
        [string] $Id
    )
    
    begin {
        #! Hack to make the json a single line / oneline
        # https://github.com/Azure/azure-cli/issues/13056
        $payloadList = $([PSCustomObject]@{
                "parameters" = , @{
                    "parameterName" = "token";
                    "redirectUrl"   = "http://localhost"
                }
            } | ConvertTo-Json -Depth 10).Replace("`r`n", "").Replace('"', '\"')
    }

    process {
        if (-not ($Id -match "/Microsoft.Web/connections/(.*)")) {
            $messageString = "The resource id supplied didn't match the expected structure. Please make sure the resource id is a <c='em'>Microsoft.Web/connections</c>."
            Write-PSFMessage -Level Host -Message $messageString
            Stop-PSFFunction -Message "Stopping because the resource id did match." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', '')))
            return
        }

        Write-PSFMessage -Level Host -Message "You will be prompted to consent the ApiConnection object: <c='em'>$($Matches[1])</c>. You <c='em'>might</c> need to supplied credentials that <c='em'>are different</c> from your personal account / credentials."
        
        $uriList = "$Id/listConsentLinks?api-version=2018-07-01-preview"

        # Get the links needed for consent
        $consentResponse = az rest --method POST --url "$uriList" --body $payloadList --query "value | [0]"  | ConvertFrom-Json -Depth 10

        # Show sign-in prompt window and grab the code after authentication
        $resUrl = Show-OAuthConsentWindow -URL $consentResponse.Link

        if ([System.String]::IsNullOrEmpty($resUrl)) {
            $messageString = "It seems that either the consent failed or you exited the consent flow before it completed. Please make sure to <c='em'>complete</c> the consent flow all the way through for this to work."
            Write-PSFMessage -Level Host -Message $messageString
            Stop-PSFFunction -Message "Stopping because result from the consent flow was empty." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', '')))
            return
        }

        $regex = '(code=)(.*)$'
        $code = ($resUrl | Select-string -pattern $regex).Matches[0].Groups[2].Value

        if ($code) {
            $payloadConfirm = $([PSCustomObject]@{code = $code } | ConvertTo-Json -Depth 10).Replace("`r`n", "").Replace('"', '\"')
        
            $uriConfirm = "$Id/confirmConsentCode?api-version=2018-07-01-preview"

            az rest --method POST --url "$uriConfirm" --body $payloadConfirm | ConvertFrom-Json -Depth 10

            if ($LastExitCode -ne 0) {
                $messageString = "There was an error while posting the <c='em'>confirmConsentCode</c> on the ApiConnection object. Try again and make sure that you used a <c='em'>user account / credential</c>."
                Write-PSFMessage -Level Host -Message $messageString
                Stop-PSFFunction -Message "Stopping because the posting of the confirmConsentCode failed." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', '')))
                return
            }
        }
    }
}