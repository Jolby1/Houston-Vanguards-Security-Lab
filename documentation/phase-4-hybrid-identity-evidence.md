# Phase 4 Hybrid Identity Evidence

- Created Azure subscription and configured a monthly budget alert.
- Created the tagged resource group `rg-hv-identity-lab`.
- Built and domain-joined the dedicated synchronization server `HV-SYNC01`.
- Registered the Microsoft Entra Cloud Sync provisioning agent.
- Created a pilot synchronization scope using `GG-Cloud-Sync-Pilot`.
- Provisioned `jrodriguez` from Active Directory to Microsoft Entra ID.
- Confirmed successful Create and Update provisioning events.
- Confirmed password hash synchronization.
- Confirmed successful first cloud sign-in and MFA registration.
- Added the synchronized user to `HV-Cloud-Identity-Readers`.
- Assigned the Reader role at the resource-group scope.
- Confirmed the synchronized user can view `rg-hv-identity-lab`.
- Confirmed the cloud identity design uses least-privilege group-based RBAC.
- Read access to `rg-hv-identity-lab` succeeded for `jrodriguez`.
- A resource-group tag update was denied with `AuthorizationFailed`, confirming the Reader boundary.

The pilot demonstrates one-way identity synchronization from Active Directory to Microsoft Entra ID and controlled Azure resource access.
