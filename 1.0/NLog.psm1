# Load/Install NLog.Dll

function Get-NLogDllPath {
    Get-ChildItem $PSScriptRoot\*\NLog.Dll -File -Recurse | Sort-Object ($_.Path) -Descending | Select-Object -First 1
}

$NLogDllPath = Get-NLogDllPath

if(!$positionOfCursor -or !(Test-Path $NLogDllPath)) {
    
    # Try to reinstall NLog

    $nuget = Get-Command nuget.exe -ErrorAction SilentlyContinue
    
    if(!($nuget)) {
        throw "Module NLog requires nuget.exe in path to reload NLog from Nuget.Org"
    }
    
    nuget.exe install NLog
}

return 

#region Initialization of this module
if(Test-Path "$PSScriptRoot\NLog.4.0.0\lib\net45\NLog.dll") {
    
    Write-Host "Loading NLog 4.0.0.0..."

    Add-Type -Path "$PSScriptRoot\NLog.4.0.0\lib\net45\NLog.dll"

} elseif((Test-Path "$PSScriptRoot\NLog.3.1.0.0")) {
    
    Write-Host "Loading NLog 3.1.0.0..."

    Add-Type -Path "$PSScriptRoot\NLog.3.1.0.0\NLog.dll"

} elseif((Test-Path "$PSScriptRoot\NLog.2.1.0.0")) {

    Write-Host "Loading NLog 2.1.0.0..."

    Add-Type -Path "$PSScriptRoot\NLog.2.1.0.0\NLog.dll"
    Add-Type -Path "$PSScriptRoot\NLog.2.1.0.0\MongoDB.Bson.dll"
    Add-Type -Path "$PSScriptRoot\NLog.2.1.0.0\MongoDB.Driver.dll"
    Add-Type -Path "$PSScriptRoot\NLog.2.1.0.0\NLog.Mongo.dll"
    
    $defaultConfig = "$PSScriptRoot\NLog.2.1.0.0\default.config.xml"

} elseif((Test-Path "$PSScriptRoot\NLog.2.0.1.2")) {
    
    Write-Host "Loading NLog 2.0.1.2..."

    Add-Type -Path "$PSScriptRoot\NLog.2.0.1.2\NLog.dll"
}

function Initialize-NLogInternalLogging{    param(        $LogFilePath = "$PSScriptRoot\nlog.internal.log",        [ValidateSet("Trace","Debug","Info","Warning","Error","Fatal")]        $LogLevelName = "Trace"    )    process {        $Env:NLOG_INTERNAL_LOG_FILE  = $LogFilePath        $Env:NLOG_INTERNAL_LOG_LEVEL  = $LogLevelName    }}

#endregion 

#region Create a Logger for a script

function Get-Logger {
    <#
    .SYNOPSIS
        Provide a Logger instance to send data to NLog.
    #>
    [CmdletBinding(SupportsShouldProcess=$false,SupportsPaging=$false,DefaultParameterSetName="byName",ConfirmImpact=[System.Management.Automation.ConfirmImpact]::None)]
    param(
        [Parameter(ParameterSetName="byName",Mandatory=$true,Position=0,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$false,ValueFromRemainingArguments=$false,DontShow=$false,HelpMessage="none")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,
        [Parameter(ParameterSetName="byInvocation",Mandatory=$true,Position=0,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$false,ValueFromRemainingArguments=$false,DontShow=$false,HelpMessage="none")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.InvocationInfo]
        $ScriptInvocation
    )
    process {
        switch($PSCmdlet.ParameterSetName)
        {
            "byName" { 
                [NLog.LogManager]::GetLogger($Name)
            }
            "byInvocation" {
                [NLog.LogManager]::GetLogger($ScriptInvocation.ScriptName)
            }
        }
    }
}

#endregion

