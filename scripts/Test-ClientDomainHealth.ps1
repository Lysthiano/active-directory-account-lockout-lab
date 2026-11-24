<#
.SYNOPSIS
    Collects basic domain-join, logon-server, and secure-channel validation data.
.DESCRIPTION
    Run on the domain-joined Windows client. Use an elevated PowerShell session
    if collecting computer-scope Group Policy results.
#>
Write-Host '--- Current identity ---' -ForegroundColor Cyan
whoami

Write-Host '--- Logon server ---' -ForegroundColor Cyan
$env:LOGONSERVER

Write-Host '--- Secure channel ---' -ForegroundColor Cyan
Test-ComputerSecureChannel -Verbose

Write-Host '--- Group Policy refresh ---' -ForegroundColor Cyan
gpupdate /force

Write-Host '--- User-scope Group Policy summary ---' -ForegroundColor Cyan
gpresult /scope user /r

Write-Host 'For a full HTML report, run in an elevated session:' -ForegroundColor Yellow
Write-Host 'gpresult /h "$env:USERPROFILE\Desktop\gp-report.html"'
