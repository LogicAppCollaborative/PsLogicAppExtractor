BeforeAll {
    mock -ModuleName "psake" Invoke-AzRestMethod {
        @{Content = "{""kind"": ""V1"",""properties"": {""displayName"": ""APICON-SB-INBOUND""},""id"": ""/subscriptions/b466443d-6eac-4513-a7f0-3579502929f00/resourceGroups/rgTest/providers/Microsoft.Web/connections/servicebus"",""name"": ""servicebus"",""type"": ""Microsoft.Web/connections"",""location"": ""westeurope""}" }
    }
}

Describe 'Testing Export-Raw.Connections.ManagedApis.DisplayName' {

    BeforeAll {
        ."$PSScriptRoot\..\..\..\internal\classes\PsLogicAppExtractor.class.ps1"

        $parms = @{}
        $parms.buildFile = "$PSScriptRoot\all.psakefile.ps1"
        $parms.nologo = $true
        
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskCounter -Value 0
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.Tools -Value 'Az.Powershell'
        
        $logicAppName = "LA-TEST-Exporter"
        $WorkPath = "$([System.IO.Path]::GetTempPath())PsLogicAppExtractor\$([System.Guid]::NewGuid().Guid)"
        New-Item -Path $WorkPath -ItemType Directory -Force -ErrorAction Ignore > $null

        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.WorkPath -Value $WorkPath
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_Raw.LogicApp.Action.Queue.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"

        Invoke-psake @parms -taskList "Export-Raw.Connections.ManagedApis.DisplayName"
        
        $resPath = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskInputNext
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
    
    It "Should have a properties.parameters property" {
        $lgObj.properties.parameters | Should -Not -Be $null
    }

    It 'Should have a properties.parameters.$connections property' {
        $lgObj.properties.parameters.'$connections' | Should -Not -Be $null
    }

    It 'Should have a properties.parameters.$connections.value property' {
        $lgObj.properties.parameters.'$connections'.value | Should -Not -Be $null
    }

    It 'Should have a properties.parameters.$connections.value.servicebus property' {
        $lgObj.properties.parameters.'$connections'.value.servicebus | Should -Not -Be $null
    }

    It 'Should be ''APICON-SB-INBOUND'' in the properties.parameters.$connections.value.servicebus.connectionName property' {
        $lgObj.properties.parameters.'$connections'.value.servicebus.connectionName | Should -BeExactly "APICON-SB-INBOUND"
    }

    # AfterAll {
    #     Write-Host "$resPath"
    # }
}