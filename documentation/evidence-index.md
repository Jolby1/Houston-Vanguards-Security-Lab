# Evidence Index

Reviewed October 5, 2026. These records distinguish observed outcomes from configured settings and remaining tests.

The evidence below comes from committed code, the operator's execution results, and screenshots reviewed during implementation. Raw portal/Windows screenshots and full exports are not committed with these records. This index is not a live re-audit of AD or Azure.

| Capability | Evidence | Strength and boundary |
|---|---|---|
| Virtualization readiness | [Host baseline](workstation-baseline.md), [KVM incident](../troubleshooting/troubleshooting.md) | Host checks recorded; current capacity can change |
| AD DS and DNS | [DC build](hv-dc01-build.md) | Domain and DNS validation recorded |
| OU and identity design | [Identity model](../identity/ad-identity-model.md), [OU script](../powershell/New-HVOrganizationalStructure.ps1) | Code and observed deployment; naming examples are not all deployed identities |
| Workstation policy | [Phase 3 evidence](phase-3-implementation-evidence.md), [GPO incident](../troubleshooting/troubleshooting.md) | Effective policy, settings and Event 4688 checked |
| File authorization | [Phase 3 test matrix](phase-3-implementation-evidence.md) | Read/write positive test and read-only negative tests |
| Windows LAPS | [Privileged-access controls](../pam/README.md) | Encrypted backup, authorized recovery and standard-user negative test; timed rotation not demonstrated |
| Hybrid provisioning | [Phase 4 evidence](phase-4-hybrid-identity-evidence.md) | User/group appearance and successful Create/Update events |
| Hybrid sign-in | [Phase 4 evidence](phase-4-hybrid-identity-evidence.md) | User-reported AD-password cloud sign-in and MFA completion |
| Azure least privilege | [Phase 4 evidence](phase-4-hybrid-identity-evidence.md) | Resource read passed; tag write denied |
| AD inventory | [Phase 5 evidence](phase-5-automation-evidence.md) | Executed report: 8 users, 64 groups, 4 computers |
| Entra inventory | [Python source](../python/Get-HVEntraInventory.py) | Initial script published/reported run; cloud totals not yet captured as evidence |
| Terraform discovery | [Configuration](../terraform/azure-foundation/main.tf), [Phase 5 evidence](phase-5-automation-evidence.md) | Existing resources read; output-only plan observed; no managed resource deployment |
| Business metrics | [Metrics record](../metrics/README.md) | Only observed counts; no measured time savings yet |

## Evidence handling

Commit source code, reviewed documentation, aggregate results and deliberately sanitized examples. Exclude raw identity inventories, credentials, authentication tokens, LAPS passwords, MFA QR codes, domain-join blobs, state files and VM media.

A future screenshot/export should state the system, test, observation date, expected result and actual result. Redact authentication material before publication. Subscription/tenant identifiers are not passwords, but unnecessary account metadata is omitted from public examples.

## Validation still required

- Inspect modified properties before claiming that a particular AD attribute reached Entra.
- Confirm detailed cloud inventory totals and field coverage.
- Record repeatable lifecycle automation tests and actual timing measurements.
- Exercise restore/failover and timed LAPS rotation before claiming those capabilities.
