# Project Status and Roadmap

Last reconciled: October 5, 2026.

This is the current progress record. The charter defines the original ambition; historical build documents describe earlier checkpoints. Completion means the agreed lab exercises were performed and documented, not that the environment meets production readiness requirements.

## Completed phases

| Phase | Outcome | Record |
|---|---|---|
| 0 | Host readiness, KVM, Git and documentation foundation | [Host baseline](workstation-baseline.md) |
| 1 | AD DS, DNS, domain and DC foundation | [DC build](hv-dc01-build.md) |
| 2 | OU/group model, standard and privileged accounts, Windows client | [Identity model](../identity/ad-identity-model.md), [client build](hv-win01-build.md) |
| 3 | Workstation security, auditing, IT share authorization and LAPS | [Phase 3 evidence](phase-3-implementation-evidence.md) |
| 4 | Entra Cloud Sync pilot, cloud authentication, group-based Reader boundary | [Phase 4 evidence](phase-4-hybrid-identity-evidence.md) |

Phase 3 and Phase 4 issue closure was confirmed by the lab operator. Phase 5 was opened and remains in progress. This file does not imply an independent audit of every live GitHub issue or current cloud setting.

## Phase 5 — Identity automation

Completed checkpoints:

- Tooling verified: PowerShell, Python, Azure CLI and Terraform.
- Terraform formatting/validation and a data-source plan completed against the existing Azure resource group.
- Terraform provider lock file committed; local state/cache excluded.
- PowerShell AD inventory executed: 8 users, 64 groups and 4 computers.
- Python Entra inventory script published and reported run by the operator.

Outstanding work:

- Validate the Entra report's aggregate counts and property coverage; no cloud counts have been recorded as evidence yet.
- Complete the separately tracked PowerShell/Microsoft Graph inventory if retained in the Phase 5 issue. The existing Python wrapper does not complete that separate task.
- Build a controlled, parameterized identity-lifecycle workflow and test preview, success, repeat-run and failure behavior.
- Measure actual execution times and a comparable manual baseline.
- Record Phase 5 evidence and lessons before closing the issue.

## Future capabilities

PIM, advanced PAM/API workflows, Key Vault, service principals, managed identities, wider lifecycle automation and Terraform-managed infrastructure remain planned. Their scope, licensing, cost and acceptance tests must be defined before implementation. Earlier schedule estimates are planning estimates, not measured completion forecasts.

## Review boundaries

- Successful provisioning events prove object processing; confirming a particular attribute requires its mapping and modified-property evidence.
- Direct privileged-group membership removal does not prove absence of nested privilege or refresh an existing logon token.
- A configured LAPS rotation interval does not prove a timed rotation test was performed.
- A Reader denial validates the tested identity, operation and resource scope at that time.
- The 1,500-person organization is a business model, not the size of the deployed lab.
