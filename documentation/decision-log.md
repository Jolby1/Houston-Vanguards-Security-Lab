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


## ADR-002 — Use an Isolated NAT Network for the Local Lab

- **Date:** 2026-08-24
- **Status:** Accepted

### Context

The Active Directory domain controller, Windows clients, and supporting systems must communicate with one another and access updates from the internet. The lab should not expose these systems directly to the household network. The home network currently uses `192.168.1.0/24`.

### Decision

Create a libvirt NAT network using the following initial design:

- Network name: `hv-lab-net`
- Subnet: `10.50.10.0/24`
- Gateway: `10.50.10.1`
- Infrastructure addresses: `10.50.10.10–49`
- Client addresses: `10.50.10.50–99`
- DHCP addresses: `10.50.10.100–199`
- Active Directory forest: `corp.hv-lab.test`
- NetBIOS domain: `HVL`

Initial systems will use:

- `HV-DC01`: `10.50.10.10`
- `HV-LNX01`: `10.50.10.30`
- `HV-WIN01`: `10.50.10.50`

### Reasons

- NAT permits outbound access for updates without placing the VMs directly on the home network.
- The dedicated subnet avoids overlap with the home network.
- Separate address ranges make infrastructure, clients, and dynamically assigned systems easier to identify.
- The domain controller needs a predictable address because domain clients depend on its DNS service.
- The `.test` namespace is suitable for a fictional lab and avoids conflicts with multicast DNS commonly associated with `.local`.

### Alternatives Considered

- **Isolated network:** Provides stronger separation but prevents convenient internet access.
- **Bridged network:** Places VMs directly on the home network and increases exposure and Wi-Fi complexity.
- **Libvirt default network:** Functional, but a project-specific network provides clearer documentation and intentional addressing.

### Consequences

- Devices on the home network cannot normally initiate connections to the lab VMs.
- Inbound access may require the Ubuntu host, explicit forwarding, or a temporary design change.
- The domain controller and other infrastructure systems require controlled address assignments.
- Domain clients must use the domain controller for DNS rather than public or household DNS.
- The NAT boundary is useful isolation but is not a substitute for host and guest security controls.


