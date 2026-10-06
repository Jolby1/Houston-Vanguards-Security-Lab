# Phase 3 — AD Security and Resource Authorization

Status: completed lab checkpoint. Issue closure and documentation publication were confirmed by the operator. Record reconciled October 5, 2026.

## Scope and systems

`HV-DC01` manages AD and policy. `HV-WIN01` is the workstation target. `HV-FS01` is a Windows Server 2025 Server Core member server hosting the IT share on `E:\Shares\IT`.

## Group Policy validation

| Control | Implementation | Observed validation |
|---|---|---|
| Workstation baseline | `HVL-Workstation-Security-Baseline`, linked to Workstations OU | `gpresult` listed the policy after its missing link was corrected |
| Session protection | 15-minute inactivity setting | Effective setting checked on the workstation |
| Endpoint baseline | Defender/real-time protection, firewall profiles, Guest restriction and LLMNR disabled | Operator confirmed expected checks |
| Audit policy | Separate `HVL-Workstation-Audit` | `auditpol` and Security Event 4688 confirmed process creation auditing |
| Local password management | `HVL-LAPS-Workstations` | Policy applied and encrypted password data appeared in AD |

The missing-link incident was encountered during implementation and documented. It was not demonstrated to have been deliberately injected or separately reproduced. See the [incident record](../troubleshooting/troubleshooting.md).

## File server and AGDLP

The server uses the `HV-Data` NTFS volume on `E:`. The share is `\\HV-FS01.corp.hv-lab.test\IT-Shared`. SMB encryption, access-based enumeration and disabled share caching were configured in the lab.

| Principal | NTFS | Share |
|---|---|---|
| SYSTEM | Full control | Not a client share assignment |
| BUILTIN Administrators | Full control | Full control |
| `HVL\DL-FS-IT-Shared-RW` | Modify | Change |
| `HVL\DL-FS-IT-Shared-RO` | Read and execute | Read |

| Test identity and path | Read | Create | Modify | Delete |
|---|---|---|---|---|
| `jrodriguez` → `GG-Dept-IT` → RW group | Passed | Passed | Passed | Passed |
| `mchen` → `GG-Role-IT-Shared-Readers` → RO group | Passed | Denied | Denied | Denied |

These are recorded operator results. Access was granted through group nesting rather than direct user ACL entries. The validated access model is stronger evidence than merely listing configured permissions.

## Windows LAPS

A cold pre-change DC backup was copied before schema extension; source/copy disk hashes matched. Schema extension initially failed for insufficient privilege, then succeeded after temporary Schema Admin elevation. Removal and a fresh sign-in were reported afterward.

Configured policy:

- Backup destination: Active Directory.
- Managed local account: `HVLocalAdmin`.
- Password encryption: enabled.
- Password length: 20; complexity: upper/lowercase, numbers and special characters.
- Maximum password age: 30 days.
- Authorized decryptor: SID of `GG-Role-LAPS-Password-Readers`.
- Post-authentication action: reset password and log off the managed account after an eight-hour grace period.

Validation:

- AD contained encrypted LAPS data for `HV-WIN01`.
- `adm0-jrodriguez` successfully decrypted the password after decryptor configuration/token troubleshooting.
- Standard user `jrodriguez`, tested from the workstation, received no password data.
- An ordinary-user interactive sign-in attempt on the DC was denied.

Limitations: the standard-user test demonstrates that tested account could not retrieve the secret. The privileged test does not independently isolate all inherited read rights or prove effective least privilege. Configured rotation and post-authentication behavior were not separately validated by a complete timed rotation exercise.

## Lessons and closure

Policy creation must be followed by linking and endpoint validation. Share access must be tested as the intended standard user. Password-read delegation and encrypted-secret decryption are separate controls.

Phase 3 documentation and issue closure were completed. Later hardening, restore drills and additional evidence remain in the [project roadmap](project-status.md), rather than being reported as already validated.
