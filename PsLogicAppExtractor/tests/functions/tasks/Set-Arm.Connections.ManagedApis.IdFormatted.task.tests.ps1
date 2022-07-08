Describe 'Set-Arm.Connections.ManagedApis.IdFormatted' {

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
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_Raw.LogicApp.Action.Queue.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"
        
        Invoke-psake @parms -taskList "Set-Raw.ApiVersion", "ConvertTo-Arm", "Set-Arm.Connections.ManagedApis.IdFormatted"

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

    It 'Should have a resources[0].properties.parameters.$connections.value property' {
        $armObj.resources[0].properties.parameters.'$connections'.value | Should -Not -Be $null
    }

    It 'Should have a resources[0].properties.parameters.$connections.value.servicebus property' {
        $armObj.resources[0].properties.parameters.'$connections'.value.servicebus | Should -Not -Be $null
    }

    It 'Should be "[format(...)]" in the resources[0].properties.parameters.$connections.value.servicebus.id property' {
        $armObj.resources[0].properties.parameters.'$connections'.value.servicebus.id | Should -BeExactly "[format('/subscriptions/{0}/providers/Microsoft.Web/locations/{1}/managedApis/servicebus', subscription().subscriptionId, parameters('logicAppLocation'))]"
    }

    It "Should have a parameters.logicAppLocation property" {
        $armObj.parameters.logicAppLocation | Should -Not -Be $null
    }

    It "Should be '[resourceGroup().location]' in the parameters.logicAppLocation.defaultValue property" {
        $armObj.parameters.logicAppLocation.defaultValue | Should -BeExactly "[resourceGroup().location]"
    }
    
    # AfterAll {
    #     Write-Host "$resPath"
    # }
}