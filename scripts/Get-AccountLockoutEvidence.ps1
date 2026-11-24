<#
.SYNOPSIS
    Retrieves recent Active Directory account-lockout events (Security Event ID 4740).
.DESCRIPTION
    Run on a domain controller or a system with access to the relevant Security log.
    Review Caller Computer Name in each event message and correlate with other evidence.
#>
param(
    [ValidateRange(1, 720)]
    [int]$HoursBack = 24
)

$filter = @{
    LogName   = 'Security'
    Id        = 4740
    StartTime = (Get-Date).AddHours(-$HoursBack)
}

Get-WinEvent -FilterHashtable $filter -ErrorAction Stop |
    Select-Object TimeCreated, Id, MachineName, Message |
    Format-List
