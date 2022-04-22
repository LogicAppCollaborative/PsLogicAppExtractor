
<#
    .SYNOPSIS
        Show the window used for OAuth consent
        
    .DESCRIPTION
        Used to handle the consent flow of ApiConnection objects, where the user needs to fill in an user account / credentials
        
        It requires human interaction to handle the consent flow, but this cmdlet helps make it a smooth process
        
    .PARAMETER Url
        The url of the endpoint where the consent flow for the specific ApiConnection object can be completed
        
    .EXAMPLE
        PS C:\> Show-OAuthConsentWindow -Url "https://logic-apis-westeurope.consent.azure-apim.net/login?data=eyJMb2dpbklkIjo..."
        
        This will invoke the consent flow
        It will prompt the user to enter an user account / credentials
        
        It returns the url, containing the code needed to complete the constent flow against the ApiConnection Object
        
    .NOTES
        This is highly inspired by the previous work of other smart people:
        https://github.com/logicappsio/LogicAppConnectionAuth/blob/master/LogicAppConnectionAuth.ps1
        https://github.com/OfficeDev/microsoft-teams-apps-requestateam/blob/master/Deployment/Scripts/deploy.ps1
        
        Author: MÃ¶tz Jensen (@Splaxi)
        
#>
function Show-OAuthConsentWindow {
    [CmdletBinding()]
    param (
        [Alias('Uri')]
        [string] $Url
    )
    Add-Type -AssemblyName System.Windows.Forms

    Write-Host "$Url"
    #Building the outer body of the form
    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width = 600; Height = 800 }
    
    #Building the inner part of the content on the form
    $web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width = 580; Height = 780; Url = ($url -f ($Scope -join "%20")) }
    
    $docComp = {
        $Global:uri = $web.Url.AbsoluteUri

        #Close on error or on returned code
        if ($Global:Uri -match "error=[^&]*|code=[^&]*") { $form.Close() }
    }

    #Register the event handler
    $web.Add_DocumentCompleted($docComp)
    
    #Construct the form
    $form.Controls.Add($web)

    $form.Add_Shown( { $form.Activate() })

    #Display the form
    $form.ShowDialog() | Out-Null

    # If below is the URL - the user exited the flow before completing the consent
    if ($Global:Uri -like "https://login.microsoftonline.com/common/oauth2/authorize*") {
        ""
    }
    else {
        $Global:Uri
    }
}