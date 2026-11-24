# Active Directory Account Lockout Investigation & Help Desk Recovery

A hands-on Windows Server and Windows 11 lab demonstrating Active Directory account administration, account-lockout investigation, Windows Security event review, Group Policy validation, and domain authentication troubleshooting.

> **Lab environment:** UTM virtualization, Windows Server 2022 domain controller (`LAB-DC01`), Windows 11 client (`LAB-CLIENT01`), and the isolated `lab.local` domain. `Alex Johnson` is a fictional test account used in the lab.

## Objectives

- Investigate a simulated domain-user account lockout.
- Identify the workstation associated with the lockout event.
- Review Windows Security events, especially Event ID **4740** (account locked out) and Event ID **4624** (successful logon).
- Verify account state and failed-password counters with Active Directory PowerShell.
- Unlock the test account and confirm that access is restored.
- Validate Group Policy processing and the client-to-domain secure channel.

## Lab architecture

| Component | Configuration |
|---|---|
| Virtualization | UTM |
| Domain | `lab.local` |
| Domain controller | `LAB-DC01` — Windows Server 2022 |
| Client | `LAB-CLIENT01` — Windows 11 |
| Test identity | `lab\\alex.johnson` (fictional) |

## Investigation workflow

1. Reproduce a lockout in the isolated lab using the test account.
2. On the domain controller, inspect Event ID 4740 and record the caller computer name.
3. Query Active Directory for `LockedOut`, `Enabled`, and `badPwdCount`.
4. Unlock the account with `Unlock-ADAccount`.
5. Confirm `LockedOut` is `False` and `badPwdCount` is reset/zero where reported.
6. On the client, verify the logged-on identity, domain logon server, Group Policy processing, and secure-channel status.
7. Review successful logon events (Event ID 4624) as supporting evidence of authentication activity.

## PowerShell examples

Run Active Directory queries from a domain controller or a machine with the Active Directory PowerShell module and appropriate permissions.

### Inspect account state

```powershell
Get-ADUser -Identity "alex.johnson" -Properties Enabled,LockedOut,badPwdCount,LastBadPasswordAttempt |
    Select-Object Name,Enabled,LockedOut,badPwdCount,LastBadPasswordAttempt
```

### Find recent account-lockout events (Event ID 4740)

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4740
    StartTime = (Get-Date).AddHours(-24)
} | Select-Object TimeCreated, Id, Message
```

Review the event message's **Caller Computer Name** field to identify the computer associated with the lockout. Correlate it with other evidence; do not assume it alone proves the root cause.

### Unlock the test account

```powershell
Unlock-ADAccount -Identity "alex.johnson"

Get-ADUser -Identity "alex.johnson" -Properties Enabled,LockedOut,badPwdCount |
    Select-Object Name,Enabled,LockedOut,badPwdCount
```

### Review successful logons (Event ID 4624)

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4624
    StartTime = (Get-Date).AddMinutes(-15)
} | Select-Object -First 20 TimeCreated, Id, Message
```

### Validate the client secure channel

Run on the domain-joined Windows client:

```powershell
Test-ComputerSecureChannel -Verbose
```

### Refresh and report Group Policy

Run in an elevated PowerShell session on the client:

```powershell
gpupdate /force
gpresult /h "$env:USERPROFILE\Desktop\gp-report.html"
Start-Process "$env:USERPROFILE\Desktop\gp-report.html"
```

If `gpresult` returns Access Denied for computer-scope data, rerun from an elevated session. User-scope results can be collected separately with `gpresult /scope user /r`.

## Findings and validation

The captured lab evidence showed:

- Event ID 4740 recorded an account-lockout event for the fictional `alex.johnson` account.
- The event identified `LAB-CLIENT01` as the caller computer.
- The account was subsequently unlocked with `Unlock-ADAccount`.
- Follow-up Active Directory queries showed `LockedOut = False` and `badPwdCount = 0` in the final validation capture.
- The client reported `LAB-DC01` as its logon server.
- `Test-ComputerSecureChannel -Verbose` returned `True`, indicating the secure channel was healthy.
- Group Policy processing completed successfully; the generated Group Policy Results report showed successful component status.

These observations demonstrate the recovery and validation workflow. They do not establish the exact original source of every failed password attempt.

## Repository contents

```text
active-directory-account-lockout-lab/
├── README.md
├── scripts/
│   ├── Get-AccountLockoutEvidence.ps1
│   ├── Get-ADUserLockoutStatus.ps1
│   ├── Unlock-TestUser.ps1
│   └── Test-ClientDomainHealth.ps1
├── documentation/
│   └── incident-report.md
└── evidence/
    └── README.md
```

## Skills demonstrated

Active Directory administration · Windows Server · Windows 11 troubleshooting · PowerShell · Group Policy · Windows Security auditing · Event ID analysis · Identity and access management · Domain authentication troubleshooting

## Safety and scope

This project was performed in an isolated, self-managed virtual lab using a fictional test identity. Do not publish real usernames, passwords, domain details, IP addresses, SIDs, or unredacted security-event data from production environments. Review and redact screenshots before committing them.
