# Recorded Lab Metrics

Last reconciled: October 5, 2026.

| Measure | Recorded value | Source / interpretation |
|---|---|---|
| AD users | 8 | Inventory execution on HV-DC01; includes built-in users |
| AD groups | 64 | Same inventory; includes built-in groups |
| AD computers | 4 | Same inventory |
| Cloud Sync pilot workforce users | 1 | Direct member jrodriguez |
| Named workstation GPOs | 3 | Baseline, audit and LAPS |
| Read-only share negative tests | 3 denied operations | Create, modify and delete |
| Azure Reader negative test | Tag update denied | AuthorizationFailed at resource-group scope |
| Terraform managed infrastructure | None in current configuration | Data sources only |
| Monthly budget notification | $25 | Alert amount, not actual spend or hard cap |

The business model describes roughly 1,500 identities. It is not a measured deployment count. No timing baseline, measured efficiency improvement, availability percentage or actual monthly cloud cost has been recorded here.

Phase 5 will measure execution time, number of objects processed, failures and repeatability. Use the same task and dataset when comparing manual and automated results. Publish aggregates rather than raw directory inventories.
