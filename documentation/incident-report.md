# Lab Incident Report: Active Directory Account Lockout

## Summary

A fictional domain test account (`alex.johnson`) was locked out during a controlled help desk troubleshooting exercise. The objective was to identify the lockout event, inspect account state, restore access, and validate domain authentication.

## Environment

- Domain: `lab.local`
- Domain controller: `LAB-DC01` (Windows Server 2022)
- Client: `LAB-CLIENT01` (Windows 11)
- Test identity: `lab\\alex.johnson`

## Evidence reviewed

| Evidence | Observation |
|---|---|
| Security Event ID 4740 | Account-lockout event recorded for the test identity |
| Caller Computer Name | `LAB-CLIENT01` |
| Active Directory account query | Final capture showed `LockedOut = False`, `badPwdCount = 0` |
| Account recovery | `Unlock-ADAccount` executed on the domain controller |
| Client logon server | `\\LAB-DC01` |
| Secure-channel test | `Test-ComputerSecureChannel` returned `True` |
| Group Policy | `gpupdate /force` completed; Group Policy Results report showed successful component status |
| Security Event ID 4624 | Successful logon events were reviewed as supporting authentication evidence |

## Resolution

The test account was unlocked using Active Directory PowerShell. The account state was queried again to verify that it was no longer locked out. The client-side secure channel and Group Policy processing were also checked.

## Conclusion

The lab demonstrated a repeatable workflow for investigating a domain account lockout, identifying the caller workstation from Event ID 4740, recovering the account, and validating domain connectivity. The available evidence identifies the caller computer but does not independently prove the precise application or process that generated the failed password attempts.

## Lessons learned

- Start with the domain controller's Event ID 4740 record when investigating a domain account lockout.
- Correlate the caller workstation with endpoint-side evidence before concluding root cause.
- Verify account state after recovery rather than assuming the unlock command succeeded.
- Use an elevated session for computer-scope Group Policy reporting.
- Distinguish successful authentication events (4624) from proof that a particular account caused a lockout.
