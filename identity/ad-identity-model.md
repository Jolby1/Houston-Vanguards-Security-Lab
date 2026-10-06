# Active Directory Identity and OU Design

## Purpose

This design establishes the initial Active Directory structure for Houston Vanguards identities, privileged accounts, service accounts, devices, and authorization groups.

## Design Principles

- Apply least privilege.
- Separate everyday and privileged identities.
- Use OUs for policy and delegated-administration boundaries.
- Use groups for department, role, and resource access.
- Keep disabled identities separate from active identities.
- Avoid using the built-in Administrator account for routine work.
- Manage privileged and non-human identities as distinct identity types.

## OU Hierarchy

```text
corp.hv-lab.test
│
├── Domain Controllers
│   └── HV-DC01
│
└── Houston Vanguards
    ├── Identities
    │   ├── Employees
    │   ├── Contractors
    │   ├── Seasonal
    │   ├── Vendors
    │   └── Disabled
    │
    ├── Privileged Identities
    │   ├── Tier 0
    │   ├── Tier 1
    │   └── Tier 2
    │
    ├── Service Accounts
    │   ├── Managed
    │   └── Legacy
    │
    ├── Devices
    │   ├── Servers
    │   └── Workstations
    │
    └── Groups
        ├── Departments
        ├── Roles
        └── Resources
```

The built-in `Domain Controllers` OU remains in its default location because Windows applies the Default Domain Controllers Policy there.

## OU and Group Responsibilities

OUs organize objects when different Group Policy settings, lifecycle controls, or administrative delegations are required.

Groups represent business membership and access. Business departments are modeled as groups rather than a deep departmental OU hierarchy because department membership changes more frequently than administrative or policy boundaries.

## Administrative Tiers

### Tier 0

Tier 0 controls the identity system and includes:

- Domain controllers
- Active Directory administration
- Domain and forest configuration
- Privileged identity infrastructure
- Future hybrid identity synchronization systems

Tier 0 credentials must not be used for email, general web browsing, or ordinary workstation administration.

### Tier 1

Tier 1 controls:

- Member servers
- Enterprise applications
- Application infrastructure

### Tier 2

Tier 2 controls:

- User workstations
- Help-desk functions
- Standard endpoint support

## Account Naming

| Identity type | Pattern | Example |
|---|---|---|
| Standard user | first initial and surname | `jrodriguez` |
| Tier 0 administrator | `adm0-` plus identifier | `adm0-jrodriguez` |
| Tier 1 administrator | `adm1-` plus identifier | `adm1-jrodriguez` |
| Tier 2 administrator | `adm2-` plus identifier | `adm2-jrodriguez` |
| Legacy service account | `svc-` plus purpose | `svc-diamondops-api` |
| Group managed service account | `gmsa-` plus purpose | `gmsa-diamondops` |
| Computer | `HV-` plus type and number | `HV-WIN01` |
| Server | `HV-` plus role and number | `HV-APP01` |

## Group Naming

| Group purpose | Pattern | Example |
|---|---|---|
| Department membership | `GG-Dept-<Department>` | `GG-Dept-Cybersecurity` |
| Business role | `GG-Role-<Role>` | `GG-Role-IAMEngineers` |
| Resource permission | `DL-<Resource>-<Access>` | `DL-DiamondOps-Reader` |
| Privileged role | `GG-Priv-<Tier>-<Role>` | `GG-Priv-T0-ADAdmins` |

`GG` identifies a global group. `DL` identifies a domain-local group.

## Authorization Model

The project will use AGDLP:

```text
Accounts
→ Global groups
→ Domain-local groups
→ Permissions
```

Example:

```text
jrodriguez
→ GG-Role-IAMEngineers
→ DL-DiamondOps-Administrator
→ DiamondOps administrator permission
```

Users are assigned to groups representing their business role. Role groups are nested into domain-local groups representing access to a specific resource. Permissions are assigned to resource groups instead of directly to individual users.

## Privileged Identity Controls

- Standard accounts do not receive Domain Admin membership.
- Tier 0 administrators use separate privileged accounts.
- The built-in Administrator account is retained for emergency recovery but not normal administration.
- Privileged account use must be attributable through security logs.
- Privileged accounts will eventually receive stronger authentication, workstation restrictions, and time-limited access controls.
- Tier boundaries will be enforced progressively as the lab gains the required systems.

## Non-Human Identities

Service identities are stored separately from human identities.

Managed service identities are preferred when supported because automated password management reduces the risks associated with manually maintained service-account passwords.

Legacy service accounts must have:

- A documented owner
- A documented purpose
- Restricted logon rights
- Least-privilege group membership
- Credential-rotation requirements
- Monitoring and periodic review

## Initial Limitations

This is a simplified single-forest lab. Separate administrative forests, privileged-access workstations, advanced delegation, and time-limited privilege will be introduced only when the environment can support and validate them.


## AGDLP Authorization Model

The Houston Vanguards domain will use AGDLP for access authorization:

**Accounts → Global Groups → Domain Local Groups → Permissions**

User and computer accounts will be placed into global groups based on business membership or role. Global groups will then be placed into domain-local groups representing access to specific resources. Permissions will be assigned to the domain-local groups.

### Pilot Access Model

The initial pilot will use the following authorization path:

`jrodriguez → GG-Dept-IT → DL-FS-IT-Shared-RW → Read/write access to the IT shared folder`

The following group types will be used:

- `GG-Dept-*` for department membership.
- `GG-Role-*` for job-role membership.
- `DL-*-RO` for read-only resource access.
- `DL-*-RW` for read/write resource access.

### Reasons

- Users do not receive resource permissions directly.
- Department and role membership can change without modifying resource permissions.
- Resource permissions remain understandable and auditable.
- The model supports least privilege and scales better than assigning permissions individually.
- Global groups describe who users are, while domain-local groups describe what access is granted.

### Consequences

- More groups must be created and maintained.
- Group naming and nesting must remain consistent.
- Troubleshooting requires checking each layer of the authorization chain.
- Incorrect group nesting could grant excessive access.

## Implementation Status — October 5, 2026

The OU model, standard/Tier 0 identities, sample workforce users and initial AGDLP groups were implemented. Both IT-share paths were tested: jrodriguez has read/write through the IT department group; mchen has read-only through GG-Role-IT-Shared-Readers. See [test results](../documentation/phase-3-implementation-evidence.md).

The Tier 1/Tier 2 account names and application service-account names above are design examples, not assertions that every example exists. The current gMSA serves Cloud Sync. Full administrative-tier enforcement and application identity governance remain incomplete.

GG-Cloud-Sync-Pilot currently resides in the built-in Users container, with jrodriguez as a direct member. Its exact DN is recorded in the [hybrid design](../architecture/entra-hybrid-identity-design.md). Cloud-managed HV-Cloud-Identity-Readers is separate from the synchronized group and grants Azure Reader access.
