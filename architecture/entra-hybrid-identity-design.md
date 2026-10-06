# Entra Hybrid Identity Design

Status: implemented pilot; reconciled October 5, 2026.

## Decision and purpose

Use Microsoft Entra Cloud Sync on the dedicated domain-member server `HV-SYNC01` to provision a limited AD pilot into Microsoft Entra ID. AD remains the source of authority for synchronized workforce attributes. Cloud resource authorization is managed separately through Azure RBAC.

The initial exercise covers users, groups, password hash synchronization and cloud sign-in. Device sync and Exchange hybrid writeback are disabled. A broader production migration is outside this checkpoint.

## Components and identities

| Component | Responsibility |
|---|---|
| `HV-DC01` | On-premises directory and DNS |
| `HV-SYNC01` | Agent host at `10.50.10.30`; outbound cloud connectivity |
| Provisioning gMSA | Ongoing AD service identity; password managed by AD |
| Cloud-native `syncadmin` | Setup identity with Hybrid Identity Administrator role |
| `GG-Cloud-Sync-Pilot` | Defines the selected pilot synchronization scope |
| Cloud `HV-Cloud-Identity-Readers` | Grants group-based Azure Reader access |

The gMSA's exact runtime identity should be read from the installed service and AD. Wizard labels and an earlier local service-logon entry differed during setup; this document does not assume they are equivalent.

The personal Microsoft account used during subscription setup encountered an authentication-context error in the agent. Registration succeeded with a tenant-native setup account. That observation does not establish that every external identity is unsupported or that `#EXT#` alone proves a user's current UserType.

## Pilot scope

Selected security group distinguished name:

```text
CN=GG-Cloud-Sync-Pilot,CN=Users,DC=corp,DC=hv-lab,DC=test
```

Direct pilot member: `jrodriguez`.

```text
CN=Jolber Rodriguez,OU=Employees,OU=Identities,OU=Houston Vanguards,DC=corp,DC=hv-lab,DC=test
```

The group currently resides in the built-in Users container. A move would change its DN and require a deliberate Cloud Sync scope update. Group filtering is used for this pilot; nested membership is not relied upon.

The local `.test` suffix is not a publicly verified sign-in domain. The observed cloud user uses the tenant's `onmicrosoft.com` suffix. No AD domain rename or custom-domain deployment has been performed.

## Azure access boundary

```text
AD jrodriguez → synchronized Entra user
             → cloud-managed HV-Cloud-Identity-Readers
             → Azure Reader at rg-hv-identity-lab
```

Membership in the sync pilot does not itself grant Azure access. The cloud Reader membership was assigned separately. Azure Reader is a resource role, not an Entra directory-administrator role.

## Configuration and validation

- Configuration enabled after on-demand testing and scope correction.
- Password hash sync enabled; successful cloud sign-in used the AD password.
- Device sync and Exchange hybrid writeback disabled.
- Accidental-deletion prevention enabled; the review screen showed threshold 500.
- User and pilot group appeared in Entra, with the group sourced from on-premises AD and the expected member.
- Create and Update events succeeded.
- MFA enrollment/sign-in completed for the pilot account.
- Resource-group read succeeded; attempted tag update returned `AuthorizationFailed`.

A deletion threshold of 500 is poorly matched to a one-user pilot: it is not evidence that a single accidental deletion would be blocked. Tuning and testing that protection is a follow-up control. Password writeback and full device identity management are not demonstrated.

## Operational cautions and recovery

Inspect scope before changing group membership or DNs. Removing an object from scope can affect its cloud lifecycle. Pausing a configuration is not the same as rolling back objects already provisioned. Review provisioning logs and target objects before manual cleanup.

The setup used temporary direct Domain Admin membership; removal was reported after configuration. Effective nested privilege and active logon tokens require separate review. The service continued running afterward. Entra setup-role lifecycle review remains an operational follow-up, not a completed just-in-time access implementation.

## Evidence

See [Phase 4 validation](../documentation/phase-4-hybrid-identity-evidence.md), [troubleshooting](../troubleshooting/troubleshooting.md), and [project status](../documentation/project-status.md).
