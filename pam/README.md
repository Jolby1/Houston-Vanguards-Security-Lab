# Privileged Access Controls

## Implemented lab controls

- Separate standard and named Tier 0 accounts.
- Built-in domain Administrator reserved for emergency recovery by operating policy.
- Windows LAPS for the workstation's HVLocalAdmin recovery account.
- Encrypted LAPS backup in AD with a configured reader/decryptor group.
- Authorized recovery succeeded; a standard-user attempt returned no password data.
- Cloud Sync uses a gMSA rather than an administrator account as its continuing service identity.
- Temporary direct administrative group assignments used for setup were reported removed.
- A cloud Reader role was assigned through a group at resource-group scope.

These demonstrate privileged-access building blocks, not a fully deployed PAM platform.

## Important boundaries

The initial administrative-identity script nests a role group into Domain Admins. Removing a later direct user membership does not remove privilege inherited through that role group. Effective privilege requires checking nested groups and the active logon token.

LAPS rotation is configured for 30 days and post-authentication reset/logoff after eight hours. A full timed rotation and recovery exercise is still unrecorded. The authorized test account is privileged, so its success alone does not prove the absence of other read privileges.

## Planned work

Privileged workstations, enforced administrative tiers, just-in-time elevation, approval workflows, PIM, session controls, privileged API integration and wider non-human identity governance remain future work.

See [account operating policy](../documentation/privileged-account-operations.md), [LAPS evidence](../documentation/phase-3-implementation-evidence.md) and [hybrid design](../architecture/entra-hybrid-identity-design.md).
