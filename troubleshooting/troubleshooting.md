# Troubleshooting Log

This log records technical failures encountered during the project, the evidence collected, the troubleshooting process, and the lessons learned.

## Incident 001 — KVM Hardware Virtualization Unavailable

### Problem

During the Ubuntu virtualization-host assessment, KVM hardware acceleration was unavailable. The `/dev/kvm` device did not exist, preventing the host from using KVM to run hardware-accelerated virtual machines.

### Evidence Collected

The following evidence was collected before attempting a fix:

- Checking `/proc/cpuinfo` returned a virtualization flag count of `0`.
- No KVM-related kernel modules appeared in the loaded-module list.
- Attempting to load the `kvm_intel` module returned `Operation not supported`.
- The `/dev/kvm` device was unavailable.
- The host was identified as a physical Lenovo ThinkPad X1 Carbon Gen 9 with an Intel Core i7-1185G7 processor.

### Hypotheses

The evidence supported the following possible causes:

1. Intel hardware virtualization was disabled in the system firmware.
2. The required KVM kernel modules were not loaded.
3. The operating system was unable to access the processor’s virtualization capability.
4. The Ubuntu installation was running inside another virtual machine without nested virtualization.

### Root Cause

Intel Virtualization Technology was disabled in the ThinkPad’s UEFI/BIOS firmware. Because the firmware did not expose the processor’s VT-x capability to Ubuntu, the operating system could not load the `kvm_intel` module or create `/dev/kvm`.

### Fix

Intel Virtualization Technology was enabled in the ThinkPad firmware. After saving the firmware change and restarting Ubuntu, the `kvm_intel` module loaded successfully.

### Verification

The fix was verified using several independent checks:

- The virtualization flag count changed from `0` to `16`.
- The `kvm_intel` and `kvm` kernel modules appeared in the loaded-module list.
- The `/dev/kvm` device existed and was assigned to the `kvm` group.
- The virtualization-host validation reported successful checks for hardware virtualization, `/dev/kvm`, virtual networking devices, IOMMU support, and the primary QEMU requirements.

Some cgroup and secure-guest warnings remained, but they did not block the planned QEMU/KVM virtual-machine workload. LXC-specific failures were considered out of scope because this lab will use virtual machines rather than LXC containers.

### Lesson Learned

Hardware support alone does not guarantee that a feature is available to the operating system. Firmware configuration determines whether the processor exposes virtualization capabilities to Ubuntu.

The investigation also reinforced the importance of collecting evidence before changing the system. The virtualization flags, kernel modules, error message, and device checks identified the affected layer and allowed the root cause to be confirmed without installing unrelated software or making unnecessary configuration changes.

## Incident 002 — Secure Boot Disabled Despite Secure Firmware

### Problem

After installing Windows Server 2025, TPM 2.0 was present and ready, but `Confirm-SecureBootUEFI` returned `False`.

### Evidence Collected

- The VM used `OVMF_CODE_4M.secboot.fd`.
- The firmware loader was marked `secure='yes'`.
- SMM was enabled.
- TPM 2.0 was present and ready.
- The NVRAM template was `OVMF_VARS_4M.fd`.
- The libvirt definition showed `enrolled-keys` set to `no`.
- The host contained the Microsoft-key template `OVMF_VARS_4M.ms.fd`.

### Hypotheses

1. The VM was using ordinary UEFI instead of Secure Boot firmware.
2. SMM was not enabled.
3. Microsoft Secure Boot keys were not enrolled.
4. The firmware and NVRAM templates were mismatched.

### Root Cause

The VM used Secure Boot-capable firmware, but its NVRAM was initialized without enrolled Microsoft keys. Libvirt therefore exposed UEFI firmware while Windows correctly reported that Secure Boot was disabled.

### Unsuccessful Change Attempt

An initial attempt changed only the NVRAM template path to `OVMF_VARS_4M.ms.fd`. Libvirt rejected the edited definition because it could not match that manual combination to a compatible registered EFI firmware configuration.

The forced-save option was not used. The invalid change was discarded, preventing an unsupported configuration from being applied.

### Fix

The existing VM XML and NVRAM were backed up. The libvirt firmware configuration was changed to request both Secure Boot and enrolled keys. Explicit loader and NVRAM selections were removed so libvirt could select its registered compatible firmware pair.

The VM was then started using the `--reset-nvram` option, which initialized NVRAM from the compatible Microsoft-key template.

### Verification

After Windows started, the following command returned `True`:

```powershell
Confirm-SecureBootUEFI
```

TPM validation also continued to report that TPM 2.0 was present and ready.

### Lesson Learned

Secure Boot requires more than Secure Boot-capable firmware. The VM also needs enrolled trusted keys, compatible NVRAM, SMM, and a supported firmware configuration.

The incident also demonstrated the value of:

- Inspecting the effective VM definition
- Using registered firmware profiles
- Creating recovery copies before changing boot state
- Rejecting an invalid configuration instead of forcing it
- Verifying security controls from inside the guest operating system


## Workstation GPO Did Not Apply Because Its OU Link Was Missing

**Date:** 2026-09-17
**Affected systems:** `HV-DC01`, `HV-WIN01`
**Status:** Resolved

### Expected Behavior

`HVL-Workstation-Security-Baseline` should have applied its computer settings to `HV-WIN01`, which resides in the Workstations OU.

### Observed Behavior

`gpresult /scope computer /r` on `HV-WIN01` showed only the Default Domain Policy. The custom workstation baseline was absent, and the expected inactivity registry value did not exist.

An initial validation was accidentally performed on `HV-DC01`. Its results correctly showed that the workstation GPO did not apply to the Domain Controllers OU.

### Troubleshooting Process

The following layers were checked independently:

1. Confirmed that `HV-WIN01` was located in the Workstations OU.
2. Confirmed that the custom GPO existed.
3. Confirmed that Computer Configuration was enabled.
4. Inspected Group Policy inheritance for the Workstations OU.
5. Reviewed GPO application permissions.
6. Refreshed policy on the intended workstation.
7. Validated effective policy with `gpresult`.
8. Validated the resulting security settings directly.

### Root Cause

The GPO had been created and configured but had not been linked to the Workstations OU.

Creating a GPO does not assign it to any users or computers. A link is required to establish its scope.

### Resolution

The GPO was linked to:

`OU=Workstations,OU=Devices,OU=Houston Vanguards,DC=corp,DC=hv-lab,DC=test`

Computer policy was refreshed on `HV-WIN01`.

### Validation

After linking:

- `gpresult` listed `HVL-Workstation-Security-Baseline` as applied.
- The 15-minute inactivity control became effective.
- LLMNR was disabled.
- Microsoft Defender and real-time protection were enabled.
- All firewall profiles were enabled.
- The local Guest account was disabled.
- The GPO did not apply to `HV-DC01`.

The separate `HVL-Workstation-Audit` GPO was later linked to the same OU. Its effective audit settings were confirmed with `auditpol`, and a test launch of Notepad generated Security event ID 4688.

### Lessons Learned

A complete GPO deployment requires four distinct stages:

`Create → Configure → Link → Validate`

The GPO editor shows intended configuration, while `gpresult`, registry checks, security tools, and event logs show effective behavior.

Testing from the wrong computer can produce misleading results. Verifying `hostname` and the current security context should be an early troubleshooting step.

A missing setting should not be corrected manually on the endpoint until GPO scope, links, permissions, and effective policy have been examined.

## Windows LAPS — Schema and Decryption Permissions

### Observed failures

Schema extension returned insufficient access rights. Later, password-read delegation rejected an unqualified group name, and an authorized recovery attempt initially reported unauthorized decryption.

### Resolution and verification

Schema extension succeeded with temporary Schema Admin membership; removal and a fresh session were reported afterward. Delegation succeeded using the domain-qualified group name. The decryptor SID and group token were reviewed/corrected, after which adm0-jrodriguez could decrypt. A standard-user test from HV-WIN01 returned no password data.

### Lesson and limits

Schema-change permission, directory read permission and encrypted-secret decryption are different checks. Use exact principal identities. The recorded sequence changed both configuration and session context, so it does not isolate a single cause for every decryption failure. A failed standard-user logon to the DC was a logon-right restriction, not the LAPS negative test.

## Cloud Sync — Setup Identity and Service Context

### Evidence

The agent encountered an embedded-browser security block, then an AADSTS50020 authentication-context error with a personal Microsoft account. A native tenant setup account succeeded. The wizard later reported inability to assign service-logon rights and that the current security context was not associated with an AD domain/forest.

### Resolution

The browser restriction was temporarily adjusted for setup and reported restored. The cloud-native setup account used Hybrid Identity Administrator. Temporary direct Domain Admin membership was used for gMSA configuration. Service-account names were inspected; the wizard label and the local policy entry differed. Configuration completed in a domain administrative session, and the service ran afterward.

### Lesson and limits

Check the executing identity, not just whether the machine is domain joined. Use the actual AD/service identity rather than assuming a displayed label is the account's SAM name. Do not infer that every external account is unsupported from one authentication failure. Removal of direct group membership does not prove removal of nested administrative privilege.

## Cloud Sync — Distinguished Names and Pilot Scope

### Evidence

A short input name returned ResourceNotFound. The pilot group's actual DN was in CN=Users, not the planned Groups OU. After scope and identifier corrections, the user appeared and successful Create/Update events were recorded.

One earlier log entry displayed Action Delete with Status Skipped and JoinNotFound.

### Resolution

The exact AD user DN was supplied to on-demand provisioning; the pilot-group DN and direct membership were corrected/verified. Continuous configuration was enabled through Review and enable. User and group presence, expected membership and later updates were confirmed.

### Lesson and limits

An accepted text field does not prove the DN is correct. A skipped Delete event does not prove an object was deleted. Successful Update status alone does not prove a specific field propagated; inspect modified properties and mappings before making that claim.

## Script Transfer — Raw URL Returned 404

The inventory download failed with 404. The failed screenshot used GetHVADInventory.ps1, while the committed filename was Get-HVADInventory.ps1. The error alone did not establish whether the repository was private.

A temporary local transfer succeeded; the HTTP server was stopped. The script ran and reported 8 users, 64 groups and 4 computers. Exact filenames and paths should be checked before changing credentials or repository access.
