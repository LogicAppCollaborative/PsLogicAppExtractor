Describe 'Set-Arm.IntegrationAccount.IdFormatted.Simple.AsVariable' {

    BeforeAll {
        # Import-Module C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor -Force

        ."$PSScriptRoot\..\..\..\internal\classes\PsLogicAppExtractor.class.ps1"
        # #."$PSScriptRoot\..\..\Set-TaskWorkDirectoryPester.ps1"

        $parms = @{}
        $parms.buildFile = "$PSScriptRoot\all.psakefile.ps1"
        $parms.nologo = $true
        
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0

        $logicAppName = "LA-TEST-Exporter"
        $WorkPath = "$([System.IO.Path]::GetTempPath())PsLogicAppExtractor\$([System.Guid]::NewGuid().Guid)"
        New-Item -Path $WorkPath -ItemType Directory -Force -ErrorAction Ignore > $null

        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.WorkPath -Value $WorkPath
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_Raw.LogicApp.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"
        
        Invoke-psake @parms -taskList "Set-Raw.ApiVersion", "ConvertTo-Arm", "Set-Arm.IntegrationAccount.IdFormatted.Simple.AsVariable"

        $resPath = Get-ExtractOutput -Path $WorkPath
        $armObj = [ArmTemplate]$(Get-Content -Path $resPath -Raw | ConvertFrom-Json)
    }

    It "Should create an output file" {
        $resPath | Should -Exist
    }

    It "Should be a valid ArmTemplate class" {
        "$($armObj.GetType())" | Should -BeExactly "ArmTemplate"
    }

    It "Should have the correct ARM `$schema" {
        $armObj.'$schema' | Should -BeExactly "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    }

    It "Should have a parameters property" {
        $armObj.parameters | Should -Not -Be $null
    }
    
    It "Should have a variables property" {
        $armObj.variables | Should -Not -Be $null
    }

    It "Should have a resources property" {
        $armObj.resources | Should -Not -Be $null
    }

    It "Should contain a single object in the resources property" {
        $armObj.resources.Count | Should -BeExactly 1
    }

    It 'Should have a resources[0].properties.integrationAccount property' {
        $armObj.resources[0].properties.integrationAccount | Should -Not -Be $null
    }

    It 'Should have a resources[0].properties.integrationAccount.id property' {
        $armObj.resources[0].properties.integrationAccount.id | Should -Not -Be $null
    }

    It 'Should be "[format(...)]" in the resources[0].properties.integrationAccount.id property' {
        $armObj.resources[0].properties.integrationAccount.id | Should -BeExactly "[format('/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/integrationAccounts/{2}',subscription().subscriptionId,resourceGroup().name,variables('integrationAccount'))]"
    }

    It "Should have a variables.integrationAccount property" {
        $armObj.variables.integrationAccount | Should -Not -Be $null
    }

    It "Should be 'Test-IntegrationAccount' in the variables.integrationAccount property" {
        $armObj.variables.integrationAccount | Should -BeExactly "Test-IntegrationAccount"
    }
    
    # AfterAll {
    #     Write-Host "$resPath"
    # }
}