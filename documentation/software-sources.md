# Software Sources and Installation Media

This document records the origin and local integrity checks for software used in the lab. Installation media and other large binaries are not stored in Git.

## Windows Server 2025 Evaluation

- Product: Windows Server 2025 Evaluation
- Intended installation: Standard Evaluation with Desktop Experience
- Architecture: x64
- Language: English (United States)
- Download date: 2026-08-24
- Source: Microsoft Evaluation Center
- Source URL: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025
- Filename: `26100.32230.260111-0550.lt_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso`
- Size: `8,152,356,864` bytes
- SHA-256: `7b052573ba7894c9924e3e87ba732ccd354d18cb75a883efa9b900ea125bfd51`
- Filesystem label: `SSS_X64FREE_EN-US_DV9`
- Bootable media detected: Yes
- Repository storage: Excluded

### Verification Method

The ISO was downloaded over HTTPS from Microsoft’s official Evaluation Center. The local file was identified as a bootable ISO 9660 filesystem. Its byte size and SHA-256 fingerprint were calculated after download.

The SHA-256 value was cross-checked against an independent catalog for the same filename and size. Because the current Microsoft download page did not display a publisher-provided checksum during verification, this record does not claim direct verification against a Microsoft-published hash.

### Evaluation Constraints

- Evaluation period: 180 days
- Internet activation required within the first 10 days after installation to avoid automatic shutdown
- Intended only for lab and evaluation use
- Latest servicing updates must be installed after deployment
