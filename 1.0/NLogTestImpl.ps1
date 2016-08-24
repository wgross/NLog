Import-Module Pester

Describe "NLog initialization" {
    BeforeAll {
        Get-ChildItem $PSScriptRoot\NLog* -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    It "Reloads the NLog nuget package if the DLL is missing" {
        Import-Module $PSScriptRoot\NLog.psm1
    }

    It "Finds a Nlog.Dll comoatible wit .Net 4.5" {
        $nlogDir = Get-ChildItem $PSScriptRoot\NLog* -Directory
        $nlogDir | Should Not Be $null
        Get-ChildItem ($nlogDir.FullName) -Filter "NLog.Dll" -File -Recurse | Where-Object { $_.FullName.Contains("net45") } | Should Not Be $null
    }

    It "Loads NLog and provides a LogManager type" {
        [type]"NLog.LogManager" | Should Not Be $null
    }
}

Describe "Get-Logger" {
    
    Import-Module $PSScriptRoot\NLog.psm1 -Force
    
    It "Returns a logger named by properties of the scrot invocation" {
        (Get-Logger -ScriptInvocation $MyInvocation).Name | Should be $MyInvocation.ScriptName
    }

    It "Returns a logger explicitely named" {
        (Get-Logger -Name "loggerName").Name | Should be "loggerName"
    }
}

