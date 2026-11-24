# PowerShell scripts

These scripts support the Active Directory account-lockout investigation and client validation workflow in this repository.

## Prerequisites

- Windows PowerShell on a supported Windows Server or Windows client.
- Active Directory Domain Services in the lab.
- The Active Directory PowerShell module for scripts that call `Get-ADUser` or `Unlock-ADAccount`.
- Appropriate read permissions for directory and Security log queries.
- Appropriate account-management permissions to unlock the test user.
- Run client health and computer-scope Group Policy checks on the domain-joined client.

> Use only in an authorized lab or environment. The default example identity is the fictional lab account `alex.johnson`.

## Script reference

| Script | Run on | Purpose |
|---|---|---|
| `Get-AccountLockoutEvidence.ps1` | Domain controller or authorized log reader | Retrieves Event ID 4740 records for a chosen time window |
| `Get-ADUserLockoutStatus.ps1` | Domain controller or AD admin workstation | Displays the selected user's account state |
| `Unlock-TestUser.ps1` | Domain controller or AD admin workstation | Checks that the account is enabled, unlocks it if locked, and verifies the result |
| `Test-ClientDomainHealth.ps1` | Domain-joined client | Reviews identity, logon server, secure channel, and Group Policy processing |

## Execution examples

Open PowerShell in the appropriate lab VM, change to the repository's `scripts` folder, and run:

### 1. Retrieve recent Event ID 4740 records

```powershell
.\Get-AccountLockoutEvidence.ps1 -HoursBack 24
```

The script displays event time, event ID, source machine, and event message. Review the **Caller Computer Name** in the message and correlate it with other evidence.

### 2. Inspect the test account

```powershell
.\Get-ADUserLockoutStatus.ps1 -Identity 'alex.johnson'
```

Review `Enabled`, `LockedOut`, `badPwdCount`, and `LastBadPasswordAttempt`.

### 3. Unlock and verify the test account

```powershell
.\Unlock-TestUser.ps1 -Identity 'alex.johnson'
```

The script checks whether the account is enabled. If it is locked, it invokes `Unlock-ADAccount -Confirm`, which prompts for confirmation, then queries the resulting account state.

### 4. Validate the client

```powershell
.\Test-ClientDomainHealth.ps1
```

The script reports the current identity, logon server, secure-channel test, Group Policy refresh, and user-scope Group Policy summary. Run an elevated session separately when you need the computer-scope HTML report:

```powershell
gpresult /h "$env:USERPROFILE\Desktop\gp-report.html"
Start-Process "$env:USERPROFILE\Desktop\gp-report.html"
```

## Notes and safe use

- Review the target identity before running account recovery.
- The unlock script intentionally does not enable a disabled account.
- Event ID 4740's caller computer is an investigative lead; it does not identify the exact executable or service responsible for failed authentication.
- Event ID 4624 is a successful-logon event and should be interpreted with its logon type and related fields.
- Run scripts with least-privilege permissions appropriate to the task.
- These scripts were authored for the lab workflow; validate them in a test environment before adapting them to another environment.
