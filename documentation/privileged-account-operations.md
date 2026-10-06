# Privileged Account Operating Policy

## Purpose

This policy defines how administrative identities are used in the Houston Vanguards lab. Its purpose is to reduce credential exposure, improve accountability, and prevent routine dependence on built-in or excessively privileged accounts.

## Account Roles

### Standard Account

`HVL\jrodriguez`

Used for:

- Normal workstation sign-in
- Documentation and routine project activity
- Testing standard-user access
- Non-administrative tasks

This account must not receive Domain Admin membership.

### Tier 0 Administrative Account

`HVL\adm0-jrodriguez`

Used for:

- Active Directory administration
- Domain controller configuration
- Domain-wide identity and group management
- Other tasks that specifically require Tier 0 authority

This account must not be used for web browsing, email, or routine workstation activity. Tier 0 credentials must not be entered on lower-trust workstations such as `HV-WIN01`.

### Built-in Administrator

The domain’s built-in SID-500 Administrator account is reserved for emergency recovery.

Routine use is prohibited. Permitted situations include:

- The named Tier 0 account is unavailable.
- Directory recovery requires the built-in account.
- A configuration failure prevents normal privileged access.
- A documented recovery procedure specifically requires it.

The account remains enabled while the lab has only one domain controller, reducing the risk of complete administrative lockout. Its description identifies it as an emergency-recovery account.

After emergency use:

1. Record why the account was used.
2. Record the date and affected system.
3. Review relevant security and system logs.
4. Rotate its password.
5. Confirm that normal Tier 0 access has been restored.

### Workstation Local Administrator

`HV-WIN01\HVLocalAdmin`

Reserved for:

- Local workstation recovery
- Initial workstation configuration
- Repairing domain trust or connectivity problems

It is not a domain administrator and must not be used as the normal workstation identity.

## Credential Separation

Each administrative and standard account must use a unique password. Passwords must not be stored in Git, scripts, screenshots, chat messages, or ordinary project documentation.

A password manager should be used for lab credentials. Temporary workforce passwords must be changed at first sign-in.

## Current Enforcement

The current controls include:

- Separate standard and Tier 0 accounts
- Initial role-group-based Domain Admin authorization; effective nested membership requires review
- Routine use of the built-in Administrator account discontinued
- Emergency-only description applied to the SID-500 account
- Tier 0 credentials excluded from `HV-WIN01`
- Offline domain join used for the workstation
- Separate local workstation recovery account protected by Windows LAPS

Some restrictions are currently procedural rather than technically enforced. Stronger enforcement through Group Policy, auditing, privileged access workstations, and future PAM controls will be introduced in later phases.

## Review

This policy must be reviewed when:

- Another domain controller is deployed.
- Privileged-access tooling is introduced.
- Account tiers or administrative roles change.
- A privileged credential is suspected of exposure.
- The built-in Administrator account is used.

## Implementation Update — October 5, 2026

Windows LAPS stores the workstation recovery password encrypted in AD. Its configured reader/decryptor group is GG-Role-LAPS-Password-Readers. Authorized decryption and a standard-user negative test were recorded. The 30-day rotation and eight-hour post-authentication action are configured, but timed behavior has not been separately demonstrated.

Cloud Sync runs under a gMSA on identity-sensitive HV-SYNC01. A cloud-native setup account was assigned Hybrid Identity Administrator. Temporary direct Domain Admin membership was reported removed after agent setup. Earlier scripts nested GG-Priv-T0-ADAdmins into Domain Admins, so direct-membership removal alone is not proof that adm0-jrodriguez lost all effective Domain Admin privilege. Active tokens also need refresh.

The policy's credential-isolation requirements are operating rules and design goals; the repository does not claim technical enforcement or verified adherence in every setup session. Review nested privileges, setup-role assignments and workstation restrictions before describing this as a fully tier-isolated environment.
