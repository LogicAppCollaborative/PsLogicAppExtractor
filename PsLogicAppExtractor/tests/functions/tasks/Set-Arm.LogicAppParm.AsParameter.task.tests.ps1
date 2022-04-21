Describe 'Testing Set-Arm.LogicApp.Parm.AsParameter' {

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
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_Raw.LogicApp.UserAssignedIdentities.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"
        
        Invoke-psake @parms -taskList "Set-Raw.ApiVersion", "Set-Raw.Actions.Http.Uri.AsParm", "Set-Raw.Actions.Http.Audience.AsParm", "ConvertTo-Arm", "Set-Arm.LogicApp.Parm.AsParameter"

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

    It "Should have a properties.definition.parameters property" {
        $armObj.resources[0].properties.definition.parameters | Should -Not -Be $null
    }

    It "Should be '[parameters('parm_EndpointAudience001')]' in the properties.definition.parameters.EndpointAudience001.defaultValue property" {
        $armObj.resources[0].properties.definition.parameters.EndpointAudience001.defaultValue | Should -BeExactly "[parameters('parm_EndpointAudience001')]"
    }

    It "Should be '[parameters('parm_EndpointUri001')]' in the properties.definition.parameters.EndpointUri001.defaultValue property" {
        $armObj.resources[0].properties.definition.parameters.EndpointUri001.defaultValue | Should -BeExactly "[parameters('parm_EndpointUri001')]"
    }

    It "Should have a parameters.parm_EndpointUri001 property" {
        $armObj.parameters.parm_EndpointUri001 | Should -Not -Be $null
    }

    It "Should be 'https://www.google.com' in the parameters.parm_EndpointUri001.defaultValue property" {
        $armObj.parameters.parm_EndpointUri001.defaultValue | Should -BeExactly "https://www.google.com"
    }

    It "Should have a parameters.parm_EndpointAudience001 property" {
        $armObj.parameters.parm_EndpointAudience001 | Should -Not -Be $null
    }

    It "Should be 'https://www.google.com' in the parameters.parm_EndpointAudience001.defaultValue property" {
        $armObj.parameters.parm_EndpointAudience001.defaultValue | Should -BeExactly "https://www.google.com"
    }

    # AfterAll {
    #     Write-Host "$resPath"
    # }
}