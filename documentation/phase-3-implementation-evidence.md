# Phase 3 Implementation Evidence

## Scope

This record summarizes the validation performed for the Active Directory security baseline, resource authorization, auditing, and Windows LAPS implementation.

## Group Policy

- `HVL-Workstation-Security-Baseline` was linked to the Workstations OU.
- `HVL-Workstation-Audit` was linked to the Workstations OU.
- `HVL-LAPS-Workstations` was linked to the Workstations OU.
- `gpresult` confirmed the intended policies applied to `HV-WIN01`.
- Security Event ID 4688 confirmed process-creation auditing.
- A controlled missing-link failure was reproduced, documented, corrected, and revalidated.

## File Server Authorization

- `HV-FS01` was domain joined and configured with the `HV-Data` volume.
- The `IT-Shared` SMB share was created.
- Read/write access was validated through `DL-FS-IT-Shared-RW`.
- Read-only access was validated through `DL-FS-IT-Shared-RO`.
- Read succeeded for the read-only account.
- Create, modify, and delete operations failed for the read-only account.
- Authorized read/write access succeeded.
- Access was assigned through group nesting rather than direct user ACLs.

## Windows LAPS

- The AD schema was extended after creating a verified domain-controller backup.
- `GG-Role-LAPS-Password-Readers` was created.
- LAPS permissions were delegated on the Workstations OU.
- Active Directory password backup and password encryption were enabled.
- `HVLocalAdmin` was configured as the managed local administrator.
- Password length was configured for 20 characters with 30-day rotation.
- Post-authentication reset and logoff behavior was configured.
- Encrypted LAPS data was confirmed for `HV-WIN01`.
- `adm0-jrodriguez` successfully decrypted the password through the authorized reader group.
- `jrodriguez` could not retrieve or decrypt the password.

## Security Outcome

The environment now uses layered controls:

- Group Policy for workstation security and auditing.
- AGDLP for resource authorization.
- NTFS and SMB permission separation.
- Windows LAPS for unique, encrypted, automatically rotated local administrator passwords.
- Privileged access restricted through dedicated groups and controlled workflows.

## Remaining Phase 3 Work

- Attach or reference final validation evidence.
- Complete the Phase 3 lessons-learned review.
- Close the Phase 3 tracking issue after documentation review.
