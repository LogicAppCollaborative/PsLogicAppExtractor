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
        $props.PsLaFilePath = "C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor\tests\functions\tasks\ConvertTo-Arm.task.test.json"

        Invoke-psake @parms -properties $props -taskList "ConvertTo-Arm"

        $resPath = Get-BuildOutput -Path $WorkPath
        $armObj = [ArmTemplate]$(Get-Content -Path $resPath -Raw | ConvertFrom-Json)
    }

    It "Should create an output file" {
        $resPath | Should -Exist
    }

    It "Should be a valid LogicApp class" {
        "$($armObj.GetType())" | Should -BeExactly "ArmTemplate"
        # $temp.name | Should -BeExactly "LA-TEST-Exporter"
        # $temp | Should -Not -Be $null
    }

    It "Should have the correct Logic App name" {
        $armObj.name | Should -BeExactly "LA-TEST-Exporter"
    }

    It "Should be of the type 'Microsoft.Logic/workflows'" {
        $armObj.type | Should -BeExactly "Microsoft.Logic/workflows"
    }
    
}