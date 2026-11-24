# Active Directory Account Lockout Investigation & Help Desk Recovery

A hands-on Windows Server and Windows 11 lab demonstrating how to investigate an Active Directory account lockout, identify the workstation associated with the event, recover the test account, and validate domain authentication and Group Policy processing.

> **Lab scope:** Isolated UTM virtual environment. The domain, hosts, and user shown below are fictional lab assets; do not reuse these settings as production recommendations.

## Project at a glance

| Item | Lab configuration |
|---|---|
| Virtualization | UTM |
| Domain | `lab.local` |
| Domain controller | `LAB-DC01` — Windows Server 2022 |
| Client | `LAB-CLIENT01` — Windows 11 |
| Test identity | `lab\alex.johnson` — fictional test account |
| Primary tools | Active Directory PowerShell, Windows Security logs, Group Policy, PowerShell |

## What I investigated

A controlled test account became locked out during a help desk troubleshooting exercise. I used the domain controller's Security log to locate the account-lockout event and identify its caller computer, checked the account state in Active Directory, unlocked the account, and validated the client-to-domain secure channel and Group Policy processing.

The caller-computer field identifies the workstation associated with the lockout event. It does not, by itself, prove which application, service, or process caused the failed password attempts.

## Lab architecture

```text
                 lab.local
                    |
              LAB-DC01
       Windows Server 2022 / AD DS
           DNS + Security Logs
                    |
          Domain-authenticated
               lab network
                    |
              LAB-CLIENT01
                Windows 11
                    |
          Fictional test identity
             alex.johnson
```

## Investigation workflow

1. **Reproduce** a controlled account-lockout scenario using the fictional test account in the isolated lab.
2. **Investigate** Security Event ID **4740** on the domain controller.
3. **Identify** the caller computer recorded in the event message and correlate it with client-side evidence.
4. **Inspect** the user's `Enabled`, `LockedOut`, `badPwdCount`, and last bad-password-attempt properties.
5. **Recover** the account with `Unlock-ADAccount`.
6. **Verify** the account is no longer locked out and review the failed-password counter.
7. **Validate** the client logon server, secure channel, and Group Policy processing.
8. **Review** Event ID **4624** records as supporting evidence of successful logon activity.

## Evidence gallery

The screenshots below are cropped from the lab VM captures and redacted where account identifiers or security identifiers appeared. Review the full-size images before relying on small text.

| Evidence | What it demonstrates |
|---|---|
| [01 — Event ID 4740](evidence/01-event-4740-lockout.png) | Account-lockout event and caller computer `LAB-CLIENT01` |
| [02 — Account status](evidence/02-account-lockout-status.png) | Active Directory account-state validation |
| [03 — Account unlock](evidence/03-account-unlock.png) | `Unlock-ADAccount` and follow-up verification |
| [04 — Secure channel](evidence/04-client-secure-channel.png) | `Test-ComputerSecureChannel` returned `True` |
| [05 — Group Policy Results](evidence/05-group-policy-results.png) | Group Policy Results report and successful component status |
| [06 — Successful logon details](evidence/06-successful-logon-events.png) | Successful logon message and Kerberos authentication details |

See [evidence/README.md](evidence/README.md) for evidence-specific notes and known screenshot limitations.

## PowerShell scripts

The `scripts/` directory contains reusable commands for the core workflow:

| Script | Purpose |
|---|---|
| [Get-AccountLockoutEvidence.ps1](scripts/Get-AccountLockoutEvidence.ps1) | Retrieves recent Security Event ID 4740 records |
| [Get-ADUserLockoutStatus.ps1](scripts/Get-ADUserLockoutStatus.ps1) | Displays account enablement, lockout, and bad-password properties |
| [Unlock-TestUser.ps1](scripts/Unlock-TestUser.ps1) | Unlocks a specified enabled test account and checks its resulting state |
| [Test-ClientDomainHealth.ps1](scripts/Test-ClientDomainHealth.ps1) | Checks current identity, logon server, secure channel, and Group Policy refresh |

See [scripts/README.md](scripts/README.md) for prerequisites, execution examples, and expected output.

## Key commands used

Run Active Directory commands on a domain controller or an authorized system with the Active Directory PowerShell module. Use an account with the permissions required for the requested operation.

### Find recent account-lockout events

```powershell
Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4740
    StartTime = (Get-Date).AddHours(-24)
} | Select-Object TimeCreated, Id, MachineName, Message
```

Review the event message's **Caller Computer Name** field. Correlate this with endpoint evidence instead of assuming it identifies the precise root cause.

### Inspect account state

```powershell
Get-ADUser -Identity 'alex.johnson' -Properties Enabled, LockedOut, badPwdCount, LastBadPasswordAttempt |
    Select-Object Name, SamAccountName, Enabled, LockedOut, badPwdCount, LastBadPasswordAttempt
```

### Unlock and verify the test account

```powershell
Unlock-ADAccount -Identity 'alex.johnson'

Get-ADUser -Identity 'alex.johnson' -Properties Enabled, LockedOut, badPwdCount |
    Select-Object Name, SamAccountName, Enabled, LockedOut, badPwdCount
```

### Validate client domain health

Run on the domain-joined client:

```powershell
whoami
$env:LOGONSERVER
Test-ComputerSecureChannel -Verbose
gpupdate /force
gpresult /scope user /r
```

For a computer-scope HTML report, run an elevated session:

```powershell
gpresult /h "$env:USERPROFILE\Desktop\gp-report.html"
Start-Process "$env:USERPROFILE\Desktop\gp-report.html"
```

### Review successful logon events

```powershell
Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4624
    StartTime = (Get-Date).AddMinutes(-15)
} | Select-Object -First 20 TimeCreated, Id, Message
```

Event ID 4624 records a successful logon. Interpret the logon type, account, authentication package, and source details in context; a successful logon record alone does not prove that the earlier lockout cause has been resolved.

## Results and validation

The lab captures and recorded command output support these results:

- A Security Event ID 4740 record was reviewed for the fictional test account.
- The event identified `LAB-CLIENT01` as the caller computer.
- The account was unlocked with Active Directory PowerShell.
- Follow-up Active Directory output showed `LockedOut = False`; a final console validation also showed `badPwdCount = 0`.
- The client reported `LAB-DC01` as its logon server.
- `Test-ComputerSecureChannel -Verbose` returned `True` and reported a healthy secure channel.
- `gpupdate /force` completed successfully, and the Group Policy Results report showed successful component status.

**Evidence qualification:** The current account-status screenshot does not visibly show the final `badPwdCount = 0` value, and the successful-logon screenshot does not include the Event ID 4624 header. The values and review are documented from the lab console work, but those two screenshots should be refreshed if the repository is expected to provide a screenshot for every individual claim. See the evidence README.

## Troubleshooting lessons

- Start with the domain controller's Event ID 4740 record for a domain account lockout.
- Use the caller computer as a lead for investigation, not as conclusive root-cause attribution.
- Verify DNS and domain-controller discovery before treating a client authentication failure as an account problem.
- Check the secure channel and logon server to distinguish account state from domain connectivity issues.
- Use an elevated session when collecting computer-scope Group Policy results.
- Verify account state after a recovery action; do not rely on the command completing without an error.
- Distinguish Event ID 4624 (successful logon) from Event ID 4740 (account locked out).

## Skills demonstrated

Active Directory administration · Windows Server 2022 · Windows 11 · PowerShell · Group Policy · Windows Security event analysis · Event IDs 4740 and 4624 · Identity and access management · Help desk troubleshooting · Domain authentication

## Safety and scope

This project was performed in an isolated, self-managed virtual lab with fictional identities. It is for learning and portfolio demonstration, not a production change procedure. Never publish real passwords, credentials, production hostnames, internal IP addresses, SIDs, or unredacted security-event data.
