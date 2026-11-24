<#
.SYNOPSIS
    Unlocks a specified test account and verifies its resulting state.
.NOTES
    Use only for an authorized lab or account-recovery workflow. Confirm identity first.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Import-Module ActiveDirectory -ErrorAction Stop
$user = Get-ADUser -Identity $Identity -Properties Enabled, LockedOut
if (-not $user.Enabled) {
    throw "Account '$Identity' is disabled. Investigate before attempting recovery."
}
if ($user.LockedOut) {
    Unlock-ADAccount -Identity $Identity -Confirm
}
Get-ADUser -Identity $Identity -Properties Enabled, LockedOut, badPwdCount |
    Select-Object Name, SamAccountName, Enabled, LockedOut, badPwdCount |
    Format-List
