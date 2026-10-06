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

Original proposed assignments (historical; the current implementation is documented below):

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

> Implementation update, October 5, 2026: `10.50.10.30` is assigned to `HV-SYNC01`; the proposed Linux guest was not deployed. `HV-WIN01` uses DHCP. See [current architecture](architecture-notes.md).

## ADR-003 — Begin at Windows Server 2016 AD Functional Level

- **Date:** 2026-09-01
- **Status:** Accepted

### Context

The `corp.hv-lab.test` forest will be created on a Windows Server 2025 domain controller. Windows Server 2025 supports both the Windows Server 2016 and Windows Server 2025 forest and domain functional levels.

The functional-level decision affects which Windows Server versions can operate as domain controllers and which Active Directory capabilities are available.

### Decision

Create the forest and domain at the Windows Server 2016 functional level.

### Reasons

- The Windows Server 2016 functional level supports domain controllers running Windows Server 2016, 2019, 2022, and 2025.
- It includes Active Directory capabilities relevant to the project, including PAM-related features, authentication policies, and authentication policy silos.
- It provides flexibility to test mixed-version domain-controller scenarios.
- The project can later assess compatibility and perform a deliberate functional-level upgrade to Windows Server 2025.
- A later upgrade provides an additional architecture, change-management, validation, and troubleshooting exercise.

### Alternatives Considered

- **Windows Server 2025 functional level:** Provides the newest AD capabilities, including support for the optional 32K database-page feature, but permits only Windows Server 2025 domain controllers.

### Consequences

- Windows Server 2025-only functional-level features will not initially be available.
- The environment retains compatibility with older supported domain-controller versions.
- A future functional-level upgrade will require compatibility assessment, validation, documentation, and a recovery plan.
- Raising the functional level is a consequential change and should not be treated as easily reversible.

## ADR-004 — Separate Policy Structure from Business Access

- **Date:** 2026-09-12
- **Status:** Accepted

### Context

Houston Vanguards contains multiple workforce types, departments, privileged roles, devices, and non-human identities. The Active Directory structure must support Group Policy, delegated administration, identity lifecycle management, and resource authorization without tightly coupling the directory to an organizational chart that may change.

### Decision

Use organizational units for policy, lifecycle, and administrative boundaries. Use security groups for department membership, business roles, privileged roles, and resource permissions.

Create separate OUs for:

- Human identity types
- Privileged identity tiers
- Managed and legacy service accounts
- Servers and workstations
- Department, role, and resource groups

Use separate Tier 0, Tier 1, and Tier 2 administrative identities. Do not grant routine administrative rights to standard user accounts.

### Reasons

- OUs provide Group Policy and delegated-administration boundaries.
- Groups can represent changing department and role membership without repeatedly restructuring the directory.
- Separate privileged identities reduce credential exposure.
- Administrative tiers limit where privileged credentials should be used.
- The structure supports AGDLP-based authorization.
- Service accounts require controls different from human identities.

### Alternatives Considered

- **Department-based OU tree:** Easy to visualize, but couples directory structure to frequently changing business organization.
- **Flat directory structure:** Simple initially, but makes policy targeting, delegation, and lifecycle separation difficult.
- **Direct user permissions:** Easy for a small environment, but difficult to audit, scale, and remove consistently.

### Consequences

- Group naming and nesting standards must be followed consistently.
- Administrators require separate accounts for different trust levels.
- More objects must be created and maintained than in a flat design.
- Group Policy must be linked carefully to avoid unintended inheritance.
- Tier enforcement will remain incomplete until dedicated administrative workstations and supporting controls are introduced.

## ADR-005 — Separate Group Policies by Target and Purpose

**Date:** 2026-09-16  
**Status:** Accepted

### Context

The Houston Vanguards domain requires security settings for domain accounts, domain controllers, workstations, auditing, and local-administrator management.

Placing all settings in one broadly linked GPO would make scope, troubleshooting, testing, and rollback difficult. Modifying the default policies for unrelated controls would also increase the risk of unintended domain-wide effects.

### Decision

Group Policy will be separated by target and purpose.

- Domain password, lockout, and Kerberos policy will remain associated with the domain-level account-policy design.
- Domain-controller policy will remain separate from workstation policy.
- General workstation controls will use `HVL-Workstation-Security-Baseline`.
- Advanced workstation auditing will use `HVL-Workstation-Audit`.
- Windows LAPS settings will use `HVL-LAPS-Workstations` after its prerequisites are evaluated.
- Workstation computer policies will be linked to the Workstations OU.
- User Configuration will be disabled in computer-only GPOs.
- Enforced and Block Inheritance will not be used without a documented requirement.

### Reasons

- Narrow scope reduces unintended policy application.
- Purpose-specific GPOs are easier to understand and audit.
- Independent GPOs can be tested, disabled, and rolled back separately.
- Separating audit settings improves evidence collection and troubleshooting.
- Preserving the intended role of default policies reduces operational risk.
- OU-based targeting aligns policy with the existing Active Directory structure.

### Alternatives Considered

#### Place all settings in the Default Domain Policy

Rejected because unrelated workstation settings would apply too broadly and make the default policy harder to maintain.

#### Create one GPO containing every workstation control

Rejected because a single failure would make individual control rollback and troubleshooting more difficult.

#### Use Enforced links for all security GPOs

Rejected because Enforced changes normal precedence and inheritance behavior without a current business requirement.

#### Use security filtering for every initial policy

Deferred because the Workstations OU already provides a clear initial scope. Additional filtering would introduce complexity before it is needed.

### Consequences

- Multiple GPOs must be named, documented, backed up, and maintained.
- Administrators must understand GPO link order and effective policy.
- Troubleshooting may require examining several policies.
- The design provides clearer ownership, safer testing, and more precise rollback.
- Additional GPOs may be introduced later as new security requirements appear.

## ADR-006 — Use a Dedicated Cloud Sync Pilot

- **Status:** Accepted and implemented in Phase 4; recorded retrospectively October 5, 2026.

### Context and Decision

Integrate a representative workforce identity with Entra before expanding synchronization. Run Cloud Sync on a dedicated domain-member server, HV-SYNC01, using a gMSA. Scope AD-to-Entra provisioning to the pilot security group's direct membership. Use the tenant onmicrosoft.com suffix for the cloud account while retaining the internal .test domain.

### Rationale and Alternatives

This fits the exercised user/group and password-hash synchronization requirements with a limited initial scope. Entra Connect Sync was considered during planning; this decision does not claim feature equivalence or a benchmark comparison. Broad directory synchronization was deferred to avoid including privileged and unrelated objects.

### Consequences

The exact group DN and membership matter. The single agent provides no demonstrated failover. The pilot's cloud Reader membership is maintained separately from sync scope. The default accidental-deletion threshold needs review before scope expansion.

See [hybrid design](../architecture/entra-hybrid-identity-design.md) and [Phase 4 evidence](phase-4-hybrid-identity-evidence.md).

## ADR-007 — Begin Automation with Discovery and Explicit Evidence

- **Status:** Accepted; Phase 5 in progress, recorded October 5, 2026.

### Decision

Start with AD/Entra inventories and Terraform data sources. Keep raw identity reports and local state out of Git. Publish aggregate observations and retain the provider lock file. Disable AzureRM automatic provider registration for the discovery configuration.

### Rationale and Consequences

Discovery builds familiarity with authentication, API output and serialization before lifecycle changes. Successful execution does not alone prove correct totals; field coverage, pagination and failure handling need validation. Existing lab provisioning scripts provide WhatIf previews but do not constitute a complete lifecycle engine. Terraform resource deployment and time-saving metrics remain future deliverables.
