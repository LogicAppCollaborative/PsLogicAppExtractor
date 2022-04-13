Describe 'Testing Set-Raw.Actions.Http.Uri.AsParm' {

    BeforeAll {
        # Import-Module C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor -Force

        ."$PSScriptRoot\..\..\..\internal\classes\PsLogicAppExtractor.class.ps1"
        #."$PSScriptRoot\..\..\Set-TaskWorkDirectoryPester.ps1"

        $parms = @{}
        $parms.buildFile = "$PSScriptRoot\all.psakefile.ps1"
        $parms.nologo = $true
        
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0

        $logicAppName = "LA-TEST-Exporter"
        $WorkPath = "$([System.IO.Path]::GetTempPath())PsLogicAppExtractor\$([System.Guid]::NewGuid().Guid)"
        New-Item -Path $WorkPath -ItemType Directory -Force -ErrorAction Ignore > $null

        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.WorkPath -Value $WorkPath
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_Raw.LogicApp.UserAssignedIdentities.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"
        
        Invoke-psake @parms -taskList "Set-Raw.Actions.Http.Uri.AsParm"

        $resPath = Get-ExtractOutput -Path $WorkPath
        $raw = Get-Content -Path $resPath -Raw
        $lgObj = [LogicApp]$(Get-Content -Path $resPath -Raw | ConvertFrom-Json)
    }

    It "Should create an output file" {
        $resPath | Should -Exist
    }

    It "Should be a valid LogicApp class" {
        "$($lgObj.GetType())" | Should -BeExactly "LogicApp"
    }

    It "Should have the correct Logic App name" {
        $lgObj.name | Should -BeExactly "LA-TEST-Exporter"
    }

    It "Should be of the type 'Microsoft.Logic/workflows'" {
        $lgObj.type | Should -BeExactly "Microsoft.Logic/workflows"
    }
    
    It "Should have a properties.definition property" {
        $lgObj.properties.definition | Should -Not -Be $null
    }

    It "Should have a properties.definition.parameters property" {
        $lgObj.properties.definition.parameters | Should -Not -Be $null
    }

    It "Should have a properties.definition.parameters.EndpointUri001 property" {
        $lgObj.properties.definition.parameters.EndpointUri001 | Should -Not -Be $null
    }

    It "Should be 'https://www.google.com' in the properties.definition.parameters.EndpointUri001.defaultValue property" {
        $lgObj.properties.definition.parameters.EndpointUri001.defaultValue | Should -BeExactly "https://www.google.com"
    }

    It 'Should match "@{parameters(''EndpointUri001'')}" in the LogicApp json' {
        $raw | Should -match "@{parameters\('EndpointUri001'\)}"
    }

    # AfterAll {
    #     Write-Host "$resPath"
    # }
}