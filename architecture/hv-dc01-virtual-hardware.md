# HV-DC01 Virtual Hardware Design

## Purpose

`HV-DC01` is the first Windows Server virtual machine in the Houston Vanguards lab. It will become the first domain controller and DNS server for the `corp.hv-lab.test` Active Directory forest.

## Virtual Hardware

| Component | Configuration |
|---|---|
| VM name | `HV-DC01` |
| Guest operating system | Windows Server 2025 Standard Evaluation |
| Installation type | Desktop Experience |
| Memory | 4096 MiB |
| Virtual CPUs | 2 |
| CPU topology | 1 socket, 2 cores, 1 thread |
| Machine type | Q35 |
| Firmware | UEFI with Secure Boot |
| TPM | Emulated TPM 2.0 using the CRB model |
| Virtual disk | 60 GiB dynamically allocated QCOW2 |
| Disk bus | SATA |
| Network | `hv-lab-net` |
| Network adapter model | `e1000e` |
| Installation media | Windows Server 2025 Evaluation x64 ISO |
| Graphical console | Enabled for guided installation |

## Planned Network Configuration

The server initially used DHCP to validate the lab network before receiving its permanent infrastructure address.

| Setting | Value |
|---|---|
| Hostname | `HV-DC01` |
| IPv4 address | `10.50.10.10` |
| Prefix length | `/24` |
| Subnet mask | `255.255.255.0` |
| Default gateway | `10.50.10.1` |
| Preferred DNS before AD DS | `10.50.10.1` |
| Preferred DNS after AD DS | `10.50.10.10` |

## Design Rationale

### Resource Allocation

Four GiB of memory and two virtual CPUs provide enough capacity for the initial Windows Server, AD DS, DNS, and Group Policy workload without overcommitting the Ubuntu host.

The 60 GiB virtual disk is dynamically allocated. Its maximum capacity is 60 GiB, but the host initially consumes only the space written by the guest.

### Firmware and Security

UEFI was selected instead of legacy BIOS to provide a modern boot architecture. Secure Boot protects the boot process by allowing trusted signed components. The emulated TPM 2.0 provides a foundation for hardware-backed security capabilities within the virtual machine.

### Disk and Network Devices

SATA and `e1000e` were selected for the guided installation because Windows Server includes compatible drivers. VirtIO devices could provide better performance but may require additional drivers during installation. VirtIO optimization can be evaluated later as a modification exercise.

### Network Placement

`HV-DC01` connects only to `hv-lab-net`, the dedicated `10.50.10.0/24` NAT network. This permits communication with future lab systems and outbound internet access while reducing direct exposure to the household network.

## Implementation Notes

Virt-manager used the Microsoft Windows Server 2022 operating-system profile because a Windows Server 2025 profile was not available. This profile affected only the initial virtual-hardware defaults; the installed operating system came from the verified Windows Server 2025 Evaluation ISO.

During validation, Windows initially reported Secure Boot as disabled. Investigation found that Secure Boot firmware was configured but Microsoft keys were not enrolled in the VM’s NVRAM. The libvirt definition was corrected to request enrolled keys, the NVRAM was safely reset, and Windows subsequently reported Secure Boot as enabled.

## Security and Repository Controls

The following items are excluded from Git:

- QCOW2 virtual disks
- ISO installation media
- NVRAM files and backups
- Administrator passwords
- TPM state
- Machine-specific secrets

The repository contains only the design, non-sensitive configuration definitions, validation results, and lessons learned.
