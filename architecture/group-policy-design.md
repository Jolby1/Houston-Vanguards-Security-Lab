# Group Policy Design

## Purpose

This document defines the initial Group Policy architecture for the Houston Vanguards Active Directory environment.

The design separates policies by purpose and scope so they can be tested, audited, disabled, or rolled back independently.

## Implementation Status — October 5, 2026

All three named workstation GPOs below were created and linked to the Workstations OU. The baseline, audit events and LAPS encrypted backup/access tests were validated. The design lists intended control categories; exact recorded results are in [Phase 3 evidence](../documentation/phase-3-implementation-evidence.md). Broader planned categories are not automatically claims of validated settings.

## Processing Model

Group Policy normally processes in this order:

`Local → Site → Domain → OU`

Computer Configuration follows the location of the computer object. User Configuration follows the location of the user object.

`HV-WIN01` resides in:

`OU=Workstations,OU=Devices,OU=Houston Vanguards,DC=corp,DC=hv-lab,DC=test`

Therefore, workstation Computer Configuration GPOs will be linked to the Workstations OU.

## Default Policy Handling

### Default Domain Policy

The Default Domain Policy will be reserved primarily for domain account policies such as:

- Password policy
- Account-lockout policy
- Kerberos policy

It will not become a general-purpose workstation security policy.

### Default Domain Controllers Policy

The Default Domain Controllers Policy will remain focused on domain-controller requirements. Workstation settings will not be added to it.

Both default policies will be reviewed and backed up before any intentional modification.

## Custom GPOs

### HVL-Workstation-Security-Baseline

**Link location:** Workstations OU  
**Configuration focus:** Computer Configuration

Planned controls include:

- Windows Defender configuration
- Windows Firewall configuration
- Session and screen-lock security
- Guest-account restrictions
- Legacy or insecure protocol restrictions
- Other general workstation controls

### HVL-Workstation-Audit

**Link location:** Workstations OU  
**Configuration focus:** Computer Configuration

Planned controls include:

- Account logon auditing
- Logon and logoff auditing
- Account-management auditing
- Policy-change auditing
- Privilege-use auditing
- Process-creation auditing
- Security-system-extension auditing

Audit settings are separated from the general baseline to make evidence collection and troubleshooting easier.

### HVL-LAPS-Workstations

**Link location:** Workstations OU  
**Configuration focus:** Computer Configuration

This GPO was created after schema preparation and permission delegation. It manages HVLocalAdmin with encrypted AD backup, 20-character passwords, 30-day rotation and an eight-hour post-authentication reset/logoff policy. See Phase 3 evidence for the distinction between configured settings and tested outcomes.

## Initial Scope

The initial GPOs will:

- Be linked only to the Workstations OU.
- Use the OU link as the primary scope control.
- Use normal inheritance.
- Not use Enforced.
- Not use Block Inheritance.
- Apply initially to `HV-WIN01`.
- Keep User Configuration disabled when the GPO contains only computer settings.

Security filtering will initially remain simple. More restrictive filtering will be introduced only when there is a documented requirement.

## Naming Convention

Custom GPOs will follow:

`HVL-[Target]-[Purpose]`

Examples:

- `HVL-Workstation-Security-Baseline`
- `HVL-Workstation-Audit`
- `HVL-LAPS-Workstations`

Names must describe both the target and the policy’s purpose.

## Change Process

For each GPO:

1. Document the intended setting and security reason.
2. Record the existing behavior.
3. Back up relevant policy state.
4. Create the GPO without immediately linking it.
5. Configure a small, controlled set of settings.
6. Review the settings report.
7. Link the GPO to the intended OU.
8. Run `gpupdate`.
9. Validate with `gpresult`, event logs, and direct behavior.
10. Record evidence and unexpected results.
11. Roll back or disable the link if validation fails.

## Design Principles

- Do not place settings at a broader scope than necessary.
- Do not edit default policies for unrelated controls.
- Do not use Enforced without a documented requirement.
- Do not use Block Inheritance as a troubleshooting shortcut.
- Separate policies by purpose when doing so improves testing and rollback.
- Prefer evidence from effective policy over assuming that a configured GPO applied.
- Test changes on the lab workstation before expanding their scope.
