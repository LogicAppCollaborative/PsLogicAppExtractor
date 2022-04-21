Describe 'Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject' {

    BeforeAll {
        ."$PSScriptRoot\..\..\..\internal\classes\PsLogicAppExtractor.class.ps1"

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
        
        Invoke-psake @parms -taskList "Set-Raw.ApiVersion", "ConvertTo-Arm", "Set-Arm.Connections.ManagedApis.Servicebus.ManagedIdentity.AsArmObject"

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

    It "Should have the needed parameters" {
        $armObj.parameters.servicebus_Namespace | Should -Not -Be $null
        $armObj.parameters.logicAppLocation | Should -Not -Be $null
    }
    
    It "Should have a resources property" {
        $armObj.resources | Should -Not -Be $null
    }

    It "Should contain a two (2) object in the resources property" {
        $armObj.resources.Count | Should -BeExactly 2
    }

    It 'Should have a resources[0].properties.parameters.$connections.value property' {
        $armObj.resources[0].properties.parameters.'$connections'.value | Should -Not -Be $null
    }

    It 'Should have a resources[0].properties.parameters.$connections.value.servicebus property' {
        $armObj.resources[0].properties.parameters.'$connections'.value.servicebus | Should -Not -Be $null
    }

    It 'Should be the same name of the connection from the LogicApp and the Name of the ApiConnection object' {
        $armObj.resources[0].properties.parameters.'$connections'.value.servicebus.connectionName | Should -BeExactly $armObj.resources[1].Name
    }

    It 'Should be the same name of the connection from the LogicApp and the DisplayName of the ApiConnection object' {
        $armObj.resources[0].properties.parameters.'$connections'.value.servicebus.connectionName | Should -BeExactly $armObj.resources[1].properties.displayName
    }

    It 'Should be "[subscriptionResourceId(...)]" in the $armObj.resources[1].properties.api.id property' {
        $armObj.resources[1].properties.api.id | Should -BeExactly "[subscriptionResourceId('Microsoft.Web/locations/managedApis', parameters('logicAppLocation'), 'servicebus')]"
    }

    It "Should be 'servicebus' in the parameters.connection_servicebus_id.defaultValue property" {
        $armObj.resources[1].properties.parameterValues.connectionString | Should -BeExactly "[listKeys(resourceId(parameters('servicebus_ResourceGroup'),'Microsoft.ServiceBus/namespaces/authorizationRules', parameters('servicebus_Namespace'), parameters('servicebus_Key')), '2017-04-01').primaryConnectionString]"
    }
    
    # AfterAll {
    #     Write-Host "$resPath"
    # }
}