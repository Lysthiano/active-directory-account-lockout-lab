<#
.SYNOPSIS
    Displays the enabled, locked-out, and bad-password state of a lab AD account.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Import-Module ActiveDirectory -ErrorAction Stop
Get-ADUser -Identity $Identity -Properties Enabled, LockedOut, badPwdCount, LastBadPasswordAttempt |
    Select-Object Name, SamAccountName, Enabled, LockedOut, badPwdCount, LastBadPasswordAttempt |
    Format-List
