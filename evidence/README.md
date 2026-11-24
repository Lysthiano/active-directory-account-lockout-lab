# Evidence screenshots

This folder contains six cropped and redacted screenshots from the isolated Active Directory account-lockout lab.

## Evidence index

| File | What it demonstrates | Evidence note |
|---|---|---|
| [01-event-4740-lockout.png](01-event-4740-lockout.png) | Security Event ID 4740 and caller computer `LAB-CLIENT01` | Account and SID details are obscured; the event and caller computer remain visible. |
| [02-account-lockout-status.png](02-account-lockout-status.png) | Active Directory account-state query after the lockout workflow | The screenshot shows the account no longer locked. It does not visibly show the final `badPwdCount = 0` value. |
| [03-account-unlock.png](03-account-unlock.png) | `Unlock-ADAccount` and follow-up status query | The account identifier is redacted; the unlocked state remains visible. |
| [04-client-secure-channel.png](04-client-secure-channel.png) | `Test-ComputerSecureChannel -Verbose` | The command returns `True` and reports that the secure channel is healthy. |
| [05-group-policy-results.png](05-group-policy-results.png) | Group Policy Results report | Successful component status and applied GPO details are visible. |
| [06-successful-logon-events.png](06-successful-logon-events.png) | Successful logon event details | Successful-logon message, logon type, and Kerberos details are visible. The Event ID 4624 header is not visible in this crop. |

## Evidence gaps to close

For a stronger, self-contained portfolio record, add two refreshed captures:

1. **Final account-state validation:** run `Get-ADUser -Identity 'alex.johnson' -Properties Enabled,LockedOut,badPwdCount | Select-Object Name,Enabled,LockedOut,badPwdCount` and capture the full output showing `LockedOut = False` and the resulting `badPwdCount`.
2. **Explicit Event ID 4624 proof:** capture the Security log event with its Event ID visible, or show `TimeCreated`, `Id`, and a relevant message excerpt from a filtered PowerShell query.

The existing README describes these results from the lab console work; these refreshed screenshots would make the visual evidence directly support each claim.

## Publication and privacy review

- These are cropped photographs of the VM display rather than native screenshots. Direct VM screenshots will be clearer when practical.
- Review each original image at full size before publishing.
- Keep real usernames, passwords, tokens, production hostnames, internal network details, and unredacted SIDs out of public evidence.
- Use fictional identities and isolated lab data only.
