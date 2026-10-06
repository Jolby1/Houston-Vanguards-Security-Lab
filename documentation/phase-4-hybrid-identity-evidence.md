# Phase 4 — Hybrid Identity Evidence

Status: completed pilot checkpoint; issue closure confirmed October 5, 2026.

## Scope

A dedicated local server integrates the AD pilot with Microsoft Entra ID. The deployed pilot contains one standard user; the fictional 1,500-person workforce is not synchronized.

| Component | Recorded configuration |
|---|---|
| Azure resource group | `rg-hv-identity-lab`, `eastus`, project/environment/phase tags |
| Budget notification | $25 monthly alert; not an automatic spending cap |
| Sync host | `HV-SYNC01`, domain member, `10.50.10.30` |
| Source directory | `corp.hv-lab.test` |
| Pilot scope | `CN=GG-Cloud-Sync-Pilot,CN=Users,DC=corp,DC=hv-lab,DC=test` |
| Pilot member | `jrodriguez`, direct member |
| Cloud resource role group | `HV-Cloud-Identity-Readers` |
| Azure role/scope | Reader on `rg-hv-identity-lab` |

## Recorded validation

| Test | Outcome | Evidence boundary |
|---|---|---|
| Domain trust on sync server | Secure channel returned True | Checked before agent setup |
| Time and connectivity | Time source was HV-DC01; TCP 443 connection to a Microsoft login endpoint succeeded | Basic prerequisite checks, not exhaustive endpoint validation |
| Agent setup | Registration/configuration completed; service running with automatic startup | gMSA setup required permission and execution-context troubleshooting |
| User provisioning | Jolber Rodriguez appeared in Entra; Create events succeeded | Full AD distinguished name used for on-demand input |
| Group provisioning | Pilot group showed on-premises AD source and expected member | Security-group pilot scoping, not nested-group validation |
| Ongoing object processing | Successful Update events on September 29 and 30 | No complete modified-property export is retained |
| Password/authentication | Operator signed in using pilot cloud UPN and current AD password | Password hash synchronization enabled; successful sign-in reported |
| MFA | Enrollment and subsequent sign-in completed | Registration for this user, not a tenant-wide MFA audit |
| Azure positive access | Synchronized user could view/read the resource group | Membership separately added to cloud Reader group |
| Azure negative access | Tag update denied with AuthorizationFailed | Validated Reader boundary for this scope and operation |

The description-change exercise was followed by an Update event, but the retained evidence does not establish that the `description` value was mapped and written to a cloud attribute. This record claims successful object updates, not a verified description-field mapping.

## Scope failure and recovery

Early provisioning returned ResourceNotFound with the short user name. The actual AD distinguished name resolved the lookup. The pilot group scope also required correction before the user appeared.

A historical log row had Action Delete, Status Skipped, with JoinNotFound. It does not prove that an existing cloud user was deleted. Subsequent successful Create and Update events are the evidence for the repaired flow.

## Review and safeguards

Configuration was reviewed as enabled, with password hash sync enabled, device sync disabled and Exchange hybrid writeback disabled. The agent was enabled. Accidental deletion protection was enabled with a displayed threshold of 500; that default threshold does not protect a single-user pilot from every accidental deletion.

Temporary direct Domain Admin membership was removed after setup and IE Enhanced Security Configuration was restored, as confirmed by the operator. Effective nested administrative membership and active tokens require separate verification.

## Closure

The negative Reader test and Phase 4 lessons were published before the issue was closed. Full-scale sync, high availability, device identity, writeback, PIM and production recovery are not completion claims for this phase.

Related: [hybrid design](../architecture/entra-hybrid-identity-design.md), [lessons](learning-journal.md), [troubleshooting](../troubleshooting/troubleshooting.md).
