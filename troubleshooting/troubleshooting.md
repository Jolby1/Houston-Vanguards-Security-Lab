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
