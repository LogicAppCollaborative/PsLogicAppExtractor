Describe 'Testing Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter' {

    BeforeAll {
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
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_Raw.LogicApp.Trigger.Recurrence.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"
        
        Invoke-psake @parms -taskList "Set-Raw.ApiVersion", "ConvertTo-Arm", "Set-Arm.Trigger.ApiConnection.Recurrence.AsParameter", "Set-Arm.Trigger.ApiConnection.EvaluatedRecurrence.AsParameter"

        $resPath = Get-ExtractOutput -Path $WorkPath
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

    It "Should have a parameters.trigger_Frequency property" {
        $armObj.parameters.trigger_Frequency | Should -Not -Be $null
    }
       
    It 'Should be "Minute" in the parameters.trigger_Frequency.defaultValue property' {
        $armObj.parameters.trigger_Frequency.defaultValue | Should -BeExactly "Minute"
    }

    It "Should have a parameters.trigger_Interval property" {
        $armObj.parameters.trigger_Interval | Should -Not -Be $null
    }

    It 'Should be 1 in the parameters.trigger_Interval.defaultValue property' {
        $armObj.parameters.trigger_Interval.defaultValue | Should -BeExactly 1
    }

    It 'Should be "[parameters(''trigger_Frequency'')]" in the properties.definition.triggers.evaluatedRecurrence.frequency property' {
        @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.evaluatedRecurrence.frequency | Should -BeExactly "[parameters('trigger_Frequency')]"
    }

    It 'Should be "[parameters(''trigger_Interval'')]" in the properties.definition.triggers.evaluatedRecurrence.interval property' {
        @($armObj.resources[0].properties.definition.triggers.PsObject.Properties)[0].Value.evaluatedRecurrence.interval | Should -BeExactly "[parameters('trigger_Interval')]"
    }

    # AfterAll {
    #     Write-Host "$resPath"
    # }
}