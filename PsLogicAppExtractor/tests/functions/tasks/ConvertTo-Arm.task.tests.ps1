Describe 'Testing ConvertTo-Arm' {

    BeforeAll {
        Import-Module C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor -Force

        ."$(Get-PSFConfigValue -FullName PsLogicAppExtractor.ModulePath.Classes)\PsLogicAppExtractor.class.ps1"
        
        $parms = @{}
        $parms.buildFile = "C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor\tests\functions\tasks\all.psakefile.ps1"
        $parms.nologo = $true
        
        $Script:TaskCounter = 0

        $WorkPath = "$([System.IO.Path]::GetTempPath())PsLogicAppExtractor\$([System.Guid]::NewGuid().Guid)"
        New-Item -Path $WorkPath -ItemType Directory -Force -ErrorAction Ignore > $null
        
        $props = @{}
        $props.PsLaWorkPath = $WorkPath
        $props.PsLaFilePath = "C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor\tests\functions\tasks\_ConvertTo.Arm.json"

        Invoke-psake @parms -properties $props -taskList "ConvertTo-Arm"

        $resPath = Get-BuildOutput -Path $WorkPath
        $armObj = [ArmTemplate]$(Get-Content -Path $resPath -Raw | ConvertFrom-Json)
    }

    It "Should create an output file" {
        $resPath | Should -Exist
    }

    It "Should be a valid LogicApp class" {
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
}