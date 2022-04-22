
<#
    .SYNOPSIS
        Start the consent flow for an ApiConnection object
        
    .DESCRIPTION
        Some of the ApiConnection objects needs an user account to consent / authenticate, before it works
        
        This cmdlet helps starting, running and completing the consent flow an ApiConnection object
        
    .PARAMETER Id
        The (resource) id of the ApiConnection object that you want to work against
        
    .EXAMPLE
        PS C:\> Invoke-PsLaConsent.AzAccount -Id "/subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/providers/Microsoft.Web/locations/westeurope/managedApis/servicebus"
        
        This will start the consent flow for the ApiConnection object
        It will prompt the user to fill in an account / credential
        It will confirm the consent directly to the ApiConnection object
        
    .NOTES
        This is highly inspired by the previous work of other smart people:
        https://github.com/logicappsio/LogicAppConnectionAuth/blob/master/LogicAppConnectionAuth.ps1
        https://github.com/OfficeDev/microsoft-teams-apps-requestateam/blob/master/Deployment/Scripts/deploy.ps1
        
        Author: Mötz Jensen (@Splaxi)
        
#>
function Invoke-PsLaConsent.AzAccount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("ResourceId")]
        [string] $Id
    )
    
    begin {
        $listParms = @{
            "parameters" = , @{
                "parameterName" = "token";
                "redirectUrl"   = "http://localhost"
            }
        }
    }

    process {
        if (-not ($Id -match "/Microsoft.Web/connections/(.*)")) {
            $messageString = "The resource id supplied didn't match the expected structure. Please make sure the resource id is a <c='em'>Microsoft.Web/connections</c>."
            Write-PSFMessage -Level Host -Message $messageString
            Stop-PSFFunction -Message "Stopping because the resource id did match." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', '')))
            return
        }

        Write-PSFMessage -Level Host -Message "You will be prompted to consent the ApiConnection object: <c='em'>$($Matches[1])</c>. You might need to supplied credentials that <c='em'>are different</c> from your personal account / credentials."

        # Get the links needed for consent
        $consentResponse = Invoke-AzResourceAction -Action "listConsentLinks" -ResourceId $Id -Parameters $listParms -Force

        # Show sign-in prompt window and grab the code after authentication
        $resUrl = Show-OAuthConsentWindow -URL $consentResponse.Value.Link

        if ([System.String]::IsNullOrEmpty($resUrl)) {
            $messageString = "It seems that either the consent failed or you exited the consent flow before it completed. Please make sure to complete the consent flow all the way through for this to work."
            Write-PSFMessage -Level Host -Message $messageString
            Stop-PSFFunction -Message "Stopping because result from the consent flow was empty." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', '')))
            return
        }

        $regex = '(code=)(.*)$'
        $code = ($resUrl | Select-string -pattern $regex).Matches[0].Groups[2].Value

        if ($code) {
            $confirmParms = @{ }
            $confirmParms.Add("code", $code)
        
            # NOTE: errors ignored as this appears to error due to a null response
            Invoke-AzResourceAction -Action "confirmConsentCode" -ResourceId $Id -Parameters $confirmParms -Force -ErrorAction Ignore
        }
    }
}