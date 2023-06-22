Describe 'Testing Set-Arm.Trigger.Cds.AsParameter' {

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
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_Raw.LogicApp.Trigger.Cds.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"
        
        Invoke-psake @parms -taskList "Set-Raw.ApiVersion", "ConvertTo-Arm", "Set-Arm.Trigger.Cds.AsParameter"

        $resPath = Get-PSFConfigValue -FullName PsLogicAppExtractor.Execution.TaskInputNext
        $raw = Get-Content -Path $resPath -Raw
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

    It "Should have a parameters.trigger_apostrophe property" {
        $armObj.parameters.trigger_apostrophe | Should -Not -Be $null
    }
       
    It 'Should be "''" in the parameters.trigger_apostrophe.defaultValue property' {
        $armObj.parameters.trigger_apostrophe.defaultValue | Should -BeExactly "'"
    }

    It "Should have a parameters.trigger_Uri property" {
        $armObj.parameters.trigger_Uri | Should -Not -Be $null
    }

    It 'Should be "https://TestEnvironment.dynamics.com" in the parameters.trigger_Uri.defaultValue property' {
        $armObj.parameters.trigger_Uri.defaultValue | Should -BeExactly "https://TestEnvironment.dynamics.com"
    }

    It 'Should be "parameters(...)" in the properties.definition.triggers.inputs.path property' {
        @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.inputs.path | Should -Match "parameters\('trigger_apostrophe'\), parameters\('trigger_Uri'\), parameters\('trigger_apostrophe'\)"
    }

    # AfterAll {
    #     Write-Host "$resPath"
    # }
}