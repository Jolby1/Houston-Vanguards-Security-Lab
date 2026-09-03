# HV-DC01 Build and Validation Record

## Purpose

`HV-DC01` is the first domain controller and DNS server for the Houston Vanguards `corp.hv-lab.test` Active Directory forest.

## Operating System

- Windows Server 2025 Standard Evaluation
- Desktop Experience
- Build 26100
- Evaluation license status: Activated
- Time zone: Eastern Time
- Windows Update restart cycles: Approximately five

## Virtual Hardware

- Memory: 4096 MiB
- Virtual CPUs: 2
- Virtual disk: 60 GiB dynamically allocated QCOW2
- Disk bus: SATA
- Firmware: UEFI with Secure Boot
- TPM: Emulated TPM 2.0
- Network adapter: `e1000e`
- Network: `hv-lab-net`

The detailed design and rationale are recorded in `architecture/hv-dc01-virtual-hardware.md`.

## Network Configuration

| Setting | Value |
|---|---|
| Hostname | `HV-DC01` |
| IPv4 address | `10.50.10.10` |
| Prefix length | `/24` |
| Default gateway | `10.50.10.1` |
| DNS client | `127.0.0.1` |
| DNS forwarder | `10.50.10.1` |

The VM initially received `10.50.10.178` from DHCP. This validated the virtual DHCP, DNS-forwarding, gateway, and NAT path before the permanent infrastructure address was configured.

After domain-controller promotion, Windows configured the DNS client to use the local loopback address. This differs from the initial plan to use `10.50.10.10`, but both addresses identify the local DNS service. The automatically configured loopback address was retained because validation succeeded.

## Active Directory Design

| Setting | Value |
|---|---|
| Forest root domain | `corp.hv-lab.test` |
| Domain DNS name | `corp.hv-lab.test` |
| NetBIOS domain | `HVL` |
| Forest functional level | Windows Server 2016 |
| Domain functional level | Windows Server 2016 |
| Global catalog | Enabled |
| DNS Server role | Installed |
| SYSVOL replication | DFS Replication |

The Windows Server 2016 functional level was selected to retain compatibility with Windows Server 2016, 2019, 2022, and 2025 domain controllers. A future upgrade to the Windows Server 2025 functional level can become a separate change-management exercise.

## Implementation Sequence

1. Created the VM using the approved virtual-hardware design.
2. Installed Windows Server 2025 Standard Evaluation with Desktop Experience.
3. Validated DHCP, DNS forwarding, NAT, and HTTPS connectivity.
4. Installed Windows updates and activated the evaluation.
5. Enabled and validated Secure Boot and TPM 2.0.
6. Changed the time zone to Eastern Time.
7. Renamed the system to `HV-DC01`.
8. Replaced DHCP with the static address `10.50.10.10/24`.
9. Installed the AD DS role and management tools.
10. Tested the forest-installation prerequisites.
11. Created `corp.hv-lab.test` and installed DNS.
12. Validated Active Directory, DNS, SYSVOL, and Netlogon.

## Validation Evidence

The following results were confirmed:

- Forest root: `corp.hv-lab.test`
- Forest mode: `Windows2016Forest`
- Domain mode: `Windows2016Domain`
- NetBIOS name: `HVL`
- NTDS service: Running
- DNS service: Running
- Netlogon service: Running
- LDAP SRV record resolved to `hv-dc01.corp.hv-lab.test`
- Domain controller address resolved to `10.50.10.10`
- `SYSVOL` share present
- `NETLOGON` share present
- External DNS resolution successful
- DC Advertising test passed
- SysVolCheck test passed
- NetLogons test passed

## Validation Findings

DCDiag initially reported recent DFS Replication and System log events. The System log contained unexpected-shutdown events from earlier VM work. DFS Replication event `2212` indicated recovery activity and was followed by successful recovery event `2214`. Event `4602` confirmed SYSVOL initialization.

Current-state AD advertising, SYSVOL, and Netlogon diagnostics passed. The findings were retained as evidence rather than hidden by clearing the event logs.

## Security Notes

- The domain Administrator and DSRM passwords are not stored in Git.
- The DSRM password is unique and stored in a password manager.
- VM disks, NVRAM, TPM state, installation media, and recovery copies are excluded from Git.
- The server is connected only to the dedicated NAT lab network.
- Secure Boot and TPM 2.0 are enabled.
- The server uses itself for AD DNS and forwards external queries through the lab gateway.

## Current Limitations

- The forest currently contains only one domain controller, creating a single point of failure.
- No tested system-state backup exists yet.
- No separate administrative accounts have been created.
- Default OUs and policies have not yet been redesigned.
- No Windows client has joined the domain.
- The lab has not yet been integrated with Microsoft Entra ID.

## Next Steps

1. Document the Secure Boot configuration incident.
2. Create the organizational-unit and administrative-tiering design.
3. Establish separate privileged and standard administrator identities.
4. Build a Windows client and join it to the domain.
5. Introduce Group Policy progressively.
