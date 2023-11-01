Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\QuickAssist.log" -Append
$QuickAssistAppName = "App.Support.QuickAssist~~~~0.0.1.0"

Write-Host "Checking for:" $QuickAssistAppName
$QuickAssist = Get-WindowsCapability -Online -Name $QuickAssistAppName

If ($QuickAssist.State -eq "Installed"){
    Write-Host "Quick Assist has been detected as being installed and will now be removed."
    Remove-WindowsCapability -online -name $QuickAssistAppName
}
else {
    Write-Host "Quick Assist is not detected as being installed. No further action will be taken."
}
Stop-Transcript