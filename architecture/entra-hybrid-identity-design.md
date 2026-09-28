# Entra Hybrid Identity Design

## Decision

The Houston Vanguards lab will use the on-premises Active Directory domain `corp.hv-lab.test` as the authoritative source for workforce identities. Microsoft Entra ID will provide cloud identity, Azure RBAC, and future hybrid access capabilities.

## Identity Boundaries

- On-premises AD remains authoritative for domain users, computers, groups, and workstation authentication.
- Entra ID will contain cloud identities and Azure resource authorization groups.
- Azure RBAC assignments will use groups rather than direct user assignments.
- Privileged cloud administration will remain separate from routine user identities.
- Synchronization will not be configured until the attribute, naming, and recovery design is documented.

## Security Principles

- Least privilege
- Group-based access
- Separation of on-premises and cloud administrative roles
- Auditable role assignments
- No direct assignment of unnecessary Owner or Contributor permissions
- Cost controls and resource tagging for Azure resources

## Current Implementation

- Azure subscription: `Azure subscription 1`
- Resource group: `rg-hv-identity-lab`
- Entra security group: `HV-Cloud-Identity-Readers`
- Assigned role: `Reader`
- Assignment scope: `rg-hv-identity-lab`

## Next Decision

Evaluate whether the lab should use Microsoft Entra Cloud Sync or Microsoft Entra Connect for synchronization after confirming the required server placement, network access, naming strategy, and rollback plan.
