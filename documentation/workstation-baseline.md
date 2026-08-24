# Workstation Baseline

## Assessment Date

2026-08-20

## Host Purpose

The ThinkPad X1 Carbon Gen 9 serves as the always-on virtualization host for the Houston Vanguards Hybrid Identity Security Engineering Lab. It will run local Active Directory and supporting infrastructure while cloud components are introduced progressively.

## Hardware

- Manufacturer: Lenovo
- Model: ThinkPad X1 Carbon Gen 9
- Processor: Intel Core i7-1185G7
- Logical CPUs: 8
- Installed memory: 32 GB
- Usable memory observed: 31 GiB
- Available memory during assessment: 25 GiB
- Storage device: 238.5 GB NVMe
- Root filesystem: ext4
- Available root-filesystem storage during assessment: 188 GiB

## Operating System

- Ubuntu 24.04.4 LTS
- Architecture: x86-64
- Kernel: Linux 7.0.0-29-generic

## Network Baseline

- Primary interface: `wlp0s20f3`
- Connection type: Wi-Fi
- Private network prefix: `/24`
- The host’s specific IP address is intentionally excluded from the public project documentation.

## Installed Engineering Tools

- Git 2.43.0
- PowerShell 7.6.5
- Python 3.12.3
- QEMU/KVM
- libvirt
- virt-manager
- OVMF

## Virtualization Validation

Intel Virtualization Technology was enabled in the system firmware after the initial assessment found it unavailable.

Post-remediation validation confirmed:

- CPU virtualization capability visible to Ubuntu
- `kvm_intel` kernel module loaded
- Generic `kvm` kernel module loaded
- `/dev/kvm` present and accessible
- QEMU hardware virtualization checks passed
- IOMMU enabled
- Virtual networking prerequisites available

The host-validation tool reported warnings related to cgroup device-controller detection and secure-guest support. LXC-specific checks also reported failures. These findings do not block the planned QEMU/KVM workload and will not be remediated without a project requirement.

## Initial Resource Plan

The initial environment will use progressive deployment rather than running every planned system simultaneously.

- Domain controller: approximately 4 GiB RAM and 2 virtual CPUs
- Windows member or client system: approximately 4 GiB RAM and 2 virtual CPUs
- Optional Linux service system: approximately 2 GiB RAM and 1–2 virtual CPUs

Resource allocation will be reviewed using measured host utilization. Virtual disk growth, operating-system updates, snapshots, and logs must be considered when monitoring storage.

## Security Notes

- Access to the `libvirt` and `kvm` groups is limited to the authorized lab administrator.
- The SSH private key remains on the ThinkPad and is protected by restrictive filesystem permissions and a passphrase.
- The corresponding public key is registered with GitHub as an authentication key.
- Secrets, private keys, machine identifiers, and unnecessary network details must not be committed to the repository.

## Current Constraints

- Preferred operating cost is $0 per month.
- Maximum cloud spending is approximately $25 per month when justified.
- The host has sufficient memory for the initial VM plan, but local storage must be monitored carefully.
- Azure and premium identity features will not be activated during Phase 0.

## Next Actions

1. Establish repository security exclusions.
2. Record initial architecture decisions.
3. Complete the Phase 0 learning journal.
4. Design the virtual network before creating virtual machines.
5. Obtain installation media from official sources.
