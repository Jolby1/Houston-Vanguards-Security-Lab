# Houston Vanguards Hybrid Identity Security Engineering Lab

## Purpose

This project is a hands-on security engineering lab designed to develop and demonstrate practical IAM, PAM, hybrid identity, automation, and Azure security engineering skills. The completed project will serve as a portfolio of architecture decisions, technical implementations, troubleshooting evidence, code, and lessons learned.

## Business Scenario

The lab models the Houston Vanguards, a fictional professional baseball organization with approximately 1,500 workforce identities. The business design includes employees, contractors, seasonal workers, privileged administrators, service accounts, application identities, and multiple departments. The deployed pilot is much smaller; application identity scenarios remain future work.

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

Phase 5 — Identity automation and infrastructure-as-code discovery.

The current work builds on the completed AD and Entra pilot with PowerShell inventory, Python reporting and Terraform discovery. Controlled lifecycle automation and measured results remain in progress.

## Status

In progress.

Phases 0 through 4 were completed and their closure was confirmed by the operator. Phase 5 is open. See [project status](project-status.md) and the [evidence index](evidence-index.md) for precise completion boundaries.

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

- Created standard and Tier 0 identities and sample employee, contractor and seasonal users.
- Designed service-account OUs; the later Cloud Sync deployment introduced a gMSA. Generic application service identities are not claimed as deployed.
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
- Documented and corrected an observed missing Group Policy link.

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

## Phase 4 — Hybrid Identity

- Created an Azure subscription, resource group, tags and budget alerts.
- Built and domain-joined HV-SYNC01 as the dedicated Cloud Sync host.
- Registered the agent with a cloud-native setup identity and configured its gMSA.
- Scoped the pilot to GG-Cloud-Sync-Pilot with jrodriguez as a direct member.
- Confirmed the synchronized user and group appeared in Entra with expected membership.
- Observed successful Create and Update provisioning events.
- Completed cloud sign-in with the AD password and MFA.
- Added the synchronized user to a separate cloud Reader group.
- Verified resource-group read access and a denied tag update.

An Update success record does not establish which attribute changed without inspecting modified properties. The description-field exercise is therefore not claimed as independently validated.

### Phase 4 lessons learned

- The personal Microsoft account sign-in failed during this agent setup; a cloud-native Hybrid Identity Administrator account succeeded. The observed error was not proof that all external identities are unsupported.
- The provisioning agent should run on a dedicated domain-member server.
- Security-group scoping requires the exact Active Directory distinguished name.
- Group-scope filtering evaluates direct members and is best used for controlled pilot scenarios.
- Successful Create and Update events confirmed the AD-to-Entra synchronization flow.
- Password hash synchronization and MFA were validated.
- Group-based Azure RBAC successfully provided Reader access.
- A denied resource-group tag update confirmed the tested account could not perform that write at the tested scope.

## Phase 5 — Automation in Progress

- Published Terraform data-source configuration; a plan read the existing resource group without planned infrastructure changes.
- Published and executed AD inventory: 8 users, 64 groups and 4 computers.
- Published the Python/Azure CLI Entra inventory and reported an initial run; aggregate cloud counts remain unrecorded.
- Identified field-coverage and error-handling work before treating cloud counts as verified.
- Kept lifecycle automation, performance measurements and final Phase 5 evidence open.

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

- Validate and harden inventory output, including missing properties and collection edge cases.
- Complete the planned Graph-specific workflow and controlled lifecycle automation.
- Record repeat-run, negative-path and dry-run results.
- Measure execution time and a comparable manual baseline.
- Continue advanced privilege and non-human identity work only with defined scope and evidence.

## Portfolio Review — October 5, 2026

Reconciled the README and evidence with completed implementation. Separated observed tests from configured settings and future capabilities. The lab does not claim 1,500 deployed accounts, complete privileged-tier enforcement, measured time savings, or production availability. Missing raw exports and remaining validation work are identified explicitly.
