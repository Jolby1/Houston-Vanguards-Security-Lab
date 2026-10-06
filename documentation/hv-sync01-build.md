# HV-SYNC01 — Cloud Sync Host Build Record

Recorded retrospectively from September 28–30, 2026 implementation.

## Implemented configuration

| Setting | Value |
|---|---|
| Platform | KVM/libvirt, Windows Server 2025 Standard Evaluation Desktop Experience |
| Allocation | 2 vCPU, 4 GiB RAM, 50 GB qcow2 maximum disk size |
| Role | Dedicated domain-member Cloud Sync host |
| IPv4 / gateway | 10.50.10.30/24 / 10.50.10.1 |
| DNS | 10.50.10.10 |
| Domain | corp.hv-lab.test |
| OU | Servers under Devices / Houston Vanguards |

UEFI Secure Boot and TPM were requested in the VM build instructions; a final guest verification result for this specific VM is not retained here. Do not infer it from the successful checks on other VMs.

## Prerequisite checks recorded

- Domain membership returned PartOfDomain True.
- The computer account was moved to the Servers OU and verified.
- Test-ComputerSecureChannel returned True.
- Windows Time reported HV-DC01 as its source.
- A TCP 443 test to a Microsoft login endpoint succeeded. This did not validate every endpoint required by Cloud Sync.

## Agent setup

The provisioning agent was downloaded and configured on this server. A cloud-native syncadmin account with Hybrid Identity Administrator was used after the personal-account login failed.

The wizard created/configured a gMSA for ongoing AD access. Domain administrative credentials authorized setup. Service-logon and security-context errors were investigated; configuration succeeded after running in a domain administrative session. Temporary direct Domain Admin membership was reported removed, and IE Enhanced Security Configuration was restored.

The provisioning service was confirmed running with automatic startup. The record does not equate removal of direct membership with removal of all inherited domain privileges.

## Pilot integration

The selected security-group scope contains jrodriguez directly. The user and group appeared in Entra, cloud sign-in worked, and the cloud Reader boundary was tested. See [hybrid design](../architecture/entra-hybrid-identity-design.md) and [Phase 4 evidence](phase-4-hybrid-identity-evidence.md).

## Operational boundaries

Protect this as identity infrastructure. One agent does not demonstrate failover. Current patch status, recovery, exact running gMSA identity, effective privileged memberships and continued agent health should be reviewed before expanding the pilot.
