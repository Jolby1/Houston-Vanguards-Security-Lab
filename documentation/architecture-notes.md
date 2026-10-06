# Current Environment Architecture

Last reconciled: October 5, 2026. Historical choices are in the [decision log](decision-log.md).

## Platform and network

The local Ubuntu 24.04 host runs QEMU/KVM, libvirt and Virtual Machine Manager. The ThinkPad has 32 GB RAM. Virtual disks use qcow2; their configured maximum capacities must not be confused with current host disk consumption.

| Setting | Implemented value |
|---|---|
| Network / bridge | `hv-lab-net` / `virbr10` |
| Subnet / gateway | `10.50.10.0/24` / `10.50.10.1` |
| DHCP pool | `10.50.10.100–199` |
| AD domain / NetBIOS | `corp.hv-lab.test` / `HVL` |
| Domain-client DNS | `10.50.10.10` |
| Domain/forest functional-level design | Windows Server 2016 |

The network uses NAT for outbound connectivity. This does not eliminate host-to-guest access or replace guest firewall controls.

## Deployed systems

| Machine | Role | Address | Notes |
|---|---|---|---|
| `HV-DC01` | Windows Server 2025 AD DS/DNS | `10.50.10.10` | Single domain controller; [build](hv-dc01-build.md) |
| `HV-WIN01` | Windows 11 Enterprise Evaluation | DHCP | Workstations OU; [build](hv-win01-build.md) |
| `HV-FS01` | Windows Server 2025 Server Core | `10.50.10.20` | Dedicated file server; data volume `E:`; [build](hv-fs01-build.md) |
| `HV-SYNC01` | Windows Server 2025 Desktop Experience | `10.50.10.30` | Domain member in Servers OU; dedicated Cloud Sync agent; [build](hv-sync01-build.md) |

The early network ADR reserved `.30` for a proposed Linux guest. The implemented assignment is now `HV-SYNC01`; no `HV-LNX01` deployment is claimed. `HV-WIN01` uses DHCP rather than the original proposed `.50`.

## Policy and trust boundaries

- OUs separate identity types, administrative tiers, service accounts, devices and groups.
- Three computer-side workstation GPOs implement the baseline, audit policy and LAPS.
- File access follows account → global group → domain-local group → SMB/NTFS permissions.
- The synchronization host is identity-sensitive infrastructure, despite being a domain member rather than a DC.
- Cloud Sync uses a gMSA for ongoing AD access. The cloud setup account and the service identity are distinct.
- Only the pilot standard user and selected pilot group are in sync scope. Domain administrative accounts are not intentionally synchronized.
- The cloud Reader security group grants resource-group access independently of sync scope.

## Cloud boundary

The implemented cloud footprint includes an Entra tenant, one Azure subscription, `rg-hv-identity-lab` in `eastus`, and `HV-Cloud-Identity-Readers` with Reader at that resource-group scope. The resource group is tagged with project, environment and phase metadata. No Azure VM deployment is claimed.

A $25 monthly budget alert was configured. Alerting does not enforce a hard spend limit. Local VM hosting does not incur Azure compute charges; cloud resource use, licenses and trial expiration remain operational responsibilities.

See the [hybrid design](../architecture/entra-hybrid-identity-design.md) for synchronization scope and the [evidence index](evidence-index.md) for tests.

## Resilience and limits

The lab has single points of failure. A pre-LAPS-schema DC backup was created and its copied disk hash matched. A successful full restore drill, additional domain controller, agent failover and production recovery objectives have not been demonstrated. Capacity planning must use current host measurements rather than the historical free-space values in build notes.
