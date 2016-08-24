# Load/Install NLog.Dll

function Get-NLogDll {
    Get-ChildItem $PSScriptRoot -Filter "NLog.Dll" -File -Recurse | Where-Object { $_.FullName.Contains("net45") }
}

$script:NLogDll = Get-NLogDll

if(!($script:NLogDll) -or !(Test-Path $NLogDll)) {
    
    # Try to reinstall NLog

    $nuget = Get-Command nuget.exe -ErrorAction SilentlyContinue
    if(!($nuget)) {
        throw "Module NLog requires nuget.exe in path to reload NLog from Nuget.Org"
    }
    
    nuget.exe install NLog

    $script:NLogDll = Get-NLogDll
}

# Load Dll

Add-Type -Path $script:NLogDll.FullName

function Initialize-NLogInternalLogging{    param(        $LogFilePath = "$PSScriptRoot\nlog.internal.log",        [ValidateSet("Trace","Debug","Info","Warning","Error","Fatal")]        $LogLevelName = "Trace"    )    process {        $Env:NLOG_INTERNAL_LOG_FILE  = $LogFilePath        $Env:NLOG_INTERNAL_LOG_LEVEL  = $LogLevelName    }}

#endregion 

#region Create a Logger for a script

function Get-Logger {
    <#
    .SYNOPSIS
        Provide a Logger instance to send data to NLog.
    #>
    [CmdletBinding(DefaultParameterSetName="byName")]
    [OutputType([NLog.Logger])]
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

