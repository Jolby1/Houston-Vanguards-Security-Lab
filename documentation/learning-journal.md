# Houston Vanguards Hybrid Identity Security Engineering Lab

## Purpose

This project is a hands-on security engineering lab designed to develop and demonstrate practical IAM, PAM, hybrid identity, automation, and Azure security engineering skills. The completed project will serve as a portfolio of architecture decisions, technical implementations, troubleshooting evidence, code, and lessons learned.

## Business Scenario

The lab models the Houston Vanguards, a fictional professional baseball organization with approximately 1,500 workforce identities. The simulated environment includes employees, contractors, seasonal workers, privileged administrators, service accounts, application identities, and multiple business departments.

## Learning Objectives

Through this project, I will learn to:

- Build and administer an Active Directory environment.
- Integrate on-premises identity systems with Microsoft Entra ID and Azure.
- Automate identity workflows with PowerShell, Python, Microsoft Graph, and REST APIs.
- Deploy and manage infrastructure using Terraform.
- Apply RBAC, least privilege, PIM, and PAM concepts.
- Secure service accounts, service principals, managed identities, secrets, and certificates.
- Troubleshoot technical failures using an evidence-based engineering process.
- Document technical decisions and implementations professionally with Git and GitHub.

## Current Phase

Phase 3 — Active Directory security baseline, resource authorization, and Windows LAPS.

The current work focuses on applying workstation security controls, validating Group Policy inheritance and enforcement, implementing AGDLP-based file-share authorization, building a domain-member file server, and deploying Windows LAPS for local administrator password management.

## Status

In progress.

Phases 0 through 2 have been completed. Phase 3 security-baseline, auditing, file-share authorization, and LAPS implementation work has been completed and validated. Final documentation, evidence collection, and lessons learned remain.

## Phase 0 — Workstation and Repository Preparation

- Validated the Ubuntu virtualization host.
- Confirmed hardware virtualization and QEMU/KVM prerequisites.
- Created the GitHub repository and initial project structure.
- Established the Git workflow for documentation and implementation changes.
- Created the architecture, documentation, PowerShell, identity, PAM, metrics, and troubleshooting areas.
- Recorded the initial project charter and architecture decision.
- Established the evidence-based troubleshooting process.

## Phase 1 — Active Directory Foundation

- Built the `corp.hv-lab.test` Active Directory forest and domain.
- Deployed `HV-DC01` as the domain controller and DNS server.
- Created the Houston Vanguards OU hierarchy.
- Created separate OUs for users, groups, devices, workstations, servers, service accounts, privileged identities, and legacy objects.
- Protected the required OUs from accidental deletion.
- Validated domain health, DNS resolution, domain-controller operation, and OU structure.
- Recorded the identity-structure architecture decision.
- Restricted routine use of the built-in Administrator account and documented the emergency-recovery purpose of that account.

## Phase 2 — Identity Model and Workstation Foundation

- Created standard, Tier 0, and service identities.
- Created departmental and role-based security groups.
- Applied the AGDLP group design.
- Built `HV-WIN01` using Windows 11 Enterprise Evaluation media.
- Configured the workstation DNS settings and domain membership.
- Used offline domain join provisioning to join the workstation.
- Validated standard-user and privileged sign-in behavior.
- Documented the separation between routine administration and privileged administration.
- Recorded installation media provenance and validation hashes.

## Phase 3 — AD Security Baseline and Resource Authorization

### Group Policy and Workstation Security

- Created and linked `HVL-Workstation-Security-Baseline`.
- Created and linked `HVL-Workstation-Audit`.
- Configured Windows Defender and firewall protections.
- Configured screen-lock and session-security settings.
- Disabled unnecessary legacy name-resolution behavior.
- Disabled the Guest account.
- Configured advanced audit policy.
- Validated effective policy with `gpresult`.
- Validated process-creation auditing with Security Event ID 4688.
- Documented and corrected a controlled Group Policy linking failure.

### File Server and AGDLP Authorization

- Built `HV-FS01` as a Windows Server 2025 member server.
- Configured UEFI Secure Boot and a virtual TPM.
- Added and formatted the data disk as `E:` with the label `HV-Data`.
- Joined the server to `corp.hv-lab.test` using offline domain join provisioning.
- Created the `IT-Shared` SMB file share.
- Applied separate NTFS and SMB permissions for read-only and read/write access.
- Validated read/write access through `DL-FS-IT-Shared-RW`.
- Validated read-only access through `DL-FS-IT-Shared-RO`.
- Confirmed that standard users could not create, modify, or delete files when assigned read-only access.
- Confirmed that authorized users could read, create, modify, and delete files when assigned read/write access.
- Used group nesting rather than direct user ACL assignments.

### Windows LAPS

- Created a pre-change backup of `HV-DC01` before modifying the AD schema.
- Extended the AD schema with the Windows LAPS attributes.
- Created `GG-Role-LAPS-Password-Readers`.
- Delegated LAPS computer self-permission on the Workstations OU.
- Delegated password-read and password-reset permissions to the LAPS reader group.
- Created and configured `HVL-LAPS-Workstations`.
- Enabled Active Directory password backup and password encryption.
- Configured management of the `HVLocalAdmin` account.
- Configured 20-character passwords with 30-day rotation.
- Configured post-authentication password reset and logoff behavior.
- Linked the LAPS policy to the Workstations OU.
- Confirmed encrypted LAPS data exists for `HV-WIN01`.
- Confirmed `adm0-jrodriguez` can decrypt the password through the authorized reader group.
- Confirmed `jrodriguez` cannot retrieve or decrypt the password.
- Confirmed the domain controller prevents ordinary users from logging on interactively.

## Engineering Lessons Learned

- Group Policy objects do not affect computers until they are linked to the correct OU.
- Policy validation must be performed on the target computer, not only on the domain controller.
- AGDLP reduces direct permission assignments and makes authorization easier to audit.
- NTFS and SMB permissions must be tested together.
- Offline domain join depends on accurate file paths, secure transfer, and matching hashes.
- Windows LAPS requires correct schema permissions, OU delegation, group membership, and authorized-decryptor configuration.
- Encrypted password storage and password-read permission are separate controls.
- Privileged group membership changes require a new logon session before the updated token is available.
- Backups and rollback planning are required before making directory-schema changes.

## Remaining Work

- Complete the final Phase 3 implementation evidence.
- Commit the learning journal and supporting documentation to GitHub.
- Record the final lessons learned and controlled-failure evidence.
- Continue to the next phase only after the Phase 3 documentation is complete.
- Do not begin Azure implementation until the project plan reaches that phase.
