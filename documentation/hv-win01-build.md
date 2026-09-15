# HV-WIN01 Build and Domain-Join Record

## Purpose

`HV-WIN01` is the first Windows workstation in the Houston Vanguards lab. It provides a lower-trust client environment for testing standard-user authentication, Active Directory group membership, Group Policy, and resource authorization.

## Build Date

September 2026

## Virtual Hardware

- **Hypervisor:** QEMU/KVM with libvirt
- **Virtual machine:** `HV-WIN01`
- **Machine type:** Q35
- **Processors:** 2 virtual CPUs
- **Memory:** 4 GiB
- **Disk:** 64 GiB dynamically allocated virtual disk
- **Disk bus:** SATA
- **Network model:** Intel e1000e
- **Virtual network:** `hv-lab-net`
- **Firmware:** UEFI with Secure Boot
- **TPM:** Emulated TPM 2.0 using the CRB model
- **Autostart:** Disabled

Autostart remains disabled because a workstation should run only when needed. This conserves host resources and reduces unnecessary exposure.

## Operating System

- **Product:** Windows 11 Enterprise Evaluation
- **Release:** 25H2
- **Build:** 26200
- **Language:** English (United States)
- **Update restarts:** 5

Installation-media provenance and its SHA-256 fingerprint are recorded in `documentation/software-sources.md`.

## Local Bootstrap Account

A local account named `HVLocalAdmin` was created during installation.

This account is reserved for local recovery and initial workstation configuration. It is separate from the domain identities and should not be used as the normal daily account.

## Network Configuration

The workstation uses DHCP because it does not provide infrastructure services that require a predictable address.

- **Subnet:** `10.50.10.0/24`
- **Gateway:** `10.50.10.1`
- **DNS server:** `10.50.10.10`
- **DNS provider:** `HV-DC01`

The client must use the domain controller for DNS so it can locate Active Directory services through domain DNS and SRV records. `HV-DC01` forwards external DNS requests through the lab gateway.

Domain DNS discovery and TCP connectivity to ports 53, 88, 389, and 445 were validated before joining the domain.

## Offline Domain Join

The workstation was joined to:

`corp.hv-lab.test`

An offline domain join was used to prevent Tier 0 credentials from being entered on the lower-trust workstation.

The process was:

1. `HV-DC01` provisioned the `HV-WIN01` computer account.
2. The computer account was placed in the Workstations OU.
3. A temporary offline-domain-join provisioning file was created.
4. The file was transferred through the isolated lab network.
5. SHA-256 hashes were compared to verify transfer integrity.
6. `HV-WIN01` applied the provisioning data locally.
7. The workstation restarted and established its domain trust.
8. All temporary copies of the provisioning file were deleted.

The computer object resides at:

`OU=Workstations,OU=Devices,OU=Houston Vanguards,DC=corp,DC=hv-lab,DC=test`

The provisioning file was treated as sensitive and was never committed to Git.

## Validation

The following results were confirmed:

- Computer name is `HV-WIN01`.
- The computer reports membership in `corp.hv-lab.test`.
- `PartOfDomain` is `True`.
- The domain secure channel test succeeds.
- `HVL\jrodriguez` can authenticate interactively.
- The standard user receives `GG-Dept-IT` membership.
- Nested membership provides `DL-FS-IT-Shared-RW`.
- The standard user is not a member of `Domain Admins`.
- Domain controller discovery succeeds.
- Group Policy results identify the domain and applied domain policy.
- Secure Boot is enabled.
- TPM 2.0 is present and ready.

## Security Decisions

- Tier 0 credentials were not entered on `HV-WIN01`.
- The local bootstrap administrator is separate from domain accounts.
- The standard account `HVL\jrodriguez` is used for routine workstation activity.
- The workstation uses the domain controller as its only configured DNS server.
- Sensitive offline-join material was removed after use.
- VM autostart is disabled.

## Lessons Learned

A domain client depends on Active Directory DNS before it can reliably locate domain controllers. Network connectivity alone is not enough.

Offline domain join separates computer provisioning from workstation enrollment. This made it possible to join the workstation without exposing a Tier 0 credential to the client.

Matching file sizes did not prove that transferred files were identical. Comparing SHA-256 hashes provided stronger integrity evidence.

Administrative PowerShell tasks require an elevated session. A local administrator account does not automatically make every PowerShell window elevated.

AGDLP group nesting becomes visible in the user’s security token after domain authentication, demonstrating how account, global-group, and domain-local-group relationships work together.
