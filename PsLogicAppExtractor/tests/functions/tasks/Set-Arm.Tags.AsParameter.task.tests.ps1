Describe 'Testing Set-Arm.Tags.AsParameter' {

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
        Set-PSFConfig -FullName PsLogicAppExtractor.Execution.TaskInputNext -Value "$PSScriptRoot\_ConvertTo.Arm.json"
        Set-PSFConfig -FullName PsLogicAppExtractor.Pester.FileName -Value "$logicAppName.json"

        Invoke-psake @parms -taskList "ConvertTo-Arm", "Set-Arm.Tags.AsParameter"

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

    It "Should have a tags property" {
        $armObj.resources[0].tags | Should -Not -Be $null
    }

    It "Should be '[parameters('tag_Department')]' in the tags.Department property" {
        $armObj.resources[0].tags.Department | Should -BeExactly "[parameters('tag_Department')]"
    }

    It "Should be '[parameters('tag_CostCenter')]' in the tags.CostCenter property" {
        $armObj.resources[0].tags.CostCenter | Should -BeExactly "[parameters('tag_CostCenter')]"
    }

    It "Should be 'Unknown' in the parameters.tag_Department.defaultValue property" {
        $armObj.parameters.tag_Department.defaultValue | Should -BeExactly "Unknown"
    }

    It "Should be 'Unassigned' in the tags.tag_CostCenter.defaultValue property" {
        $armObj.parameters.tag_CostCenter.defaultValue | Should -BeExactly "Unassigned"
    }

    # AfterAll {
    #     Write-Host "$resPath"
    # }
}