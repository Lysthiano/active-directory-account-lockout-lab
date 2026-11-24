# Evidence screenshots

This folder contains reviewed, redacted screenshots from the isolated Active Directory account-lockout lab. The screenshots are cropped from the supplied VM captures; account names and security identifiers are obscured where visible.

## Evidence files

| File | What it demonstrates | Review note |
|---|---|---|
| `01-event-4740-lockout.png` | Event ID 4740 and caller computer `LAB-CLIENT01` | Account name and SID redacted; event ID and caller host remain visible. |
| `02-account-lockout-status.png` | Post-unlock account status | `LockedOut = False` is visible. The supplied frame does not show a final `badPwdCount` value; capture a fresh `Get-ADUser` result with `badPwdCount` if that field must be evidenced in this image. |
| `03-account-unlock.png` | `Unlock-ADAccount` command and follow-up verification | Account identifier redacted; post-unlock `LockedOut = False` remains visible. |
| `04-client-secure-channel.png` | `Test-ComputerSecureChannel -Verbose` | `True` and the healthy secure-channel message are visible; interactive username redacted. |
| `05-group-policy-results.png` | Group Policy Results report | Successful component statuses and applied GPO section are visible; user identity redacted. |
| `06-successful-logon-events.png` | Successful logon event details | Successful-logon message, logon type, and Kerberos authentication details are visible. The event ID itself is not shown in this crop, so capture the Event Viewer header or `Id` field if you need explicit 4624 proof. |

## Before publishing

- These are photographs of the VM display, not direct screen captures. Replace them with direct VM screenshots when practical for a cleaner portfolio.
- Review the redactions at full size before committing. Do not publish passwords, real credentials, production identifiers, or unredacted SIDs.
- The two noted evidence gaps (`badPwdCount` final value and visible Event ID 4624) should be closed with fresh screenshots if the repository claims those exact values as screenshot-verified.
