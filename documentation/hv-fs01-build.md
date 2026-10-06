# HV-FS01 — File Server Build Record

Recorded retrospectively from completed lab work; reconciled October 5, 2026.

## Implemented configuration

| Setting | Value |
|---|---|
| Platform | KVM/libvirt, Windows Server 2025 Standard Evaluation Server Core |
| Role | Domain-member file server |
| VM allocation | 2 vCPU, approximately 3 GiB RAM, 50 GiB OS disk |
| Data disk | 20 GiB, GPT, NTFS, E: labeled HV-Data |
| Network | hv-lab-net; 10.50.10.20/24; gateway 10.50.10.1 |
| DNS / domain | 10.50.10.10 / corp.hv-lab.test |
| Firmware/security | UEFI Secure Boot and virtual TPM 2.0 validated |
| Share | IT-Shared at E:\Shares\IT |

These are configured allocations, not current host storage consumption.

## Build and validation

Windows Server Core was installed from the recorded Server evaluation media. Secure Boot initially lacked enrolled keys and TPM was absent; firmware/TPM configuration was corrected and checked from the guest. The data disk was initialized as GPT and formatted NTFS. E: was used because D: was occupied by the installation media.

Offline domain join was provisioned on the DC, transferred with hash comparison, applied on the file server and completed after restart. A transfer with mismatched hashes was repeated before use. Path/parameter errors were corrected rather than treated as successful join attempts. Domain membership and secure channel were subsequently confirmed; temporary provisioning files were removed.

## Authorization outcome

Share and NTFS permissions grant access to domain-local resource groups. The read/write and read-only tests succeeded as expected. See [Phase 3 evidence](phase-3-implementation-evidence.md) for the precise principal/permission and test matrices.

## Limits

This is one server without a tested cluster, backup restore exercise or availability target. The share configuration is documented but no complete share-deployment script is currently committed.
