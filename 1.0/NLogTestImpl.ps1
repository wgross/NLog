Import-Module Pester

Describe "NLog initialization" {
    BeforeAll {
        Get-ChildItem $PSScriptRoot/NLog* -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    It "Reloads the NLog nuget package if the DLL is missing" {
        Import-Module $PSScriptRoot\NLog.psm1
    }    
}