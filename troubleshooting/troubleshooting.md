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

