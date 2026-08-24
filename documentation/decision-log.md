# Architecture Decision Log

## ADR-001 — Use KVM and libvirt for Local Virtualization

- **Date:** 2026-08-24
- **Status:** Accepted

### Context

The project requires local Windows Server, Active Directory, and supporting systems. The ThinkPad runs Ubuntu 24.04 with 32 GB of memory and approximately 188 GiB of available storage. The lab should minimize recurring costs.

### Decision

Use QEMU/KVM with libvirt and virt-manager as the local virtualization platform.

### Reasons

- KVM provides hardware-accelerated virtualization on Ubuntu.
- The required tools are available without licensing costs.
- libvirt supports repeatable management of virtual machines, networks, and storage.
- virt-manager provides a graphical interface while the underlying concepts are being learned.
- The platform fits the project’s preferred monthly budget of $0.

### Alternatives Considered

- **VirtualBox:** Familiar and accessible, but adds another virtualization stack when KVM integrates directly with Linux.
- **VMware Workstation:** Capable, but unnecessary for the current requirements and may introduce licensing or compatibility considerations.
- **Azure-only deployment:** Reduces local hardware use but creates recurring costs and does not provide the same local hybrid-environment experience.

### Consequences

- The administrator requires privileged membership in the `libvirt` and `kvm` groups.
- VM resource consumption and disk growth must be monitored.
- Windows licensing and installation media must be handled appropriately.
- The project will initially use virt-manager but may later introduce command-line or automated VM management.
