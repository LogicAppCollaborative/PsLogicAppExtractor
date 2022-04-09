Describe 'Testing ConvertTo-LogicApp.Basic' {

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
        $props.PsLaFilePath = "C:\GIT\GITHUB\PsLogicAppExtractor.Workspace\PsLogicAppExtractor\PsLogicAppExtractor\tests\functions\tasks\_ConvertTo.Basic.json"

        Invoke-psake @parms -properties $props -taskList "ConvertTo-LogicApp.Basic"

        $resPath = Get-BuildOutput -Path $WorkPath
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
    
}