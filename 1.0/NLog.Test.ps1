# The test just starts a new powershell to verify DLL loading during initialization in a different process

Start-Process -FilePath (Get-Command powershell).Path -ArgumentList @("/noprofile", "/c" ,"$PSScriptRoot\NLogTestImpl.ps1") -NoNewWindow -Wait

