# Automation Guide

This repository contains lab provisioning scripts and initial inventory workflows. It does not recreate the entire four-VM/cloud environment with one command.

## Execution and side effects

| Artifact | Where to run | Prerequisites | Effect |
|---|---|---|---|
| [New-HVOrganizationalStructure.ps1](../powershell/New-HVOrganizationalStructure.ps1) | Windows with AD tools | Directory permissions; intended domain | Creates OUs; supports WhatIf |
| [New-HVAccessGroups.ps1](../powershell/New-HVAccessGroups.ps1) | Windows with AD tools | Required OUs and administrative rights | Creates/nests initial groups; supports WhatIf |
| [New-HVAdministrativeIdentities.ps1](../powershell/New-HVAdministrativeIdentities.ps1) | Windows with AD tools | Administrative rights | Creates named identities and Tier 0 authorization; supports WhatIf |
| [New-HVSampleIdentities.ps1](../powershell/New-HVSampleIdentities.ps1) | Windows with AD tools | OUs/groups already present | Creates sample workforce accounts/memberships; supports WhatIf |
| [Get-HVADInventory.ps1](../powershell/Get-HVADInventory.ps1) | HV-DC01 or Windows management host | ActiveDirectory module and directory read access | Reads AD; writes a local JSON report |
| [Get-HVEntraInventory.py](../python/Get-HVEntraInventory.py) | Ubuntu | Python 3, Azure CLI, authenticated directory access | Reads cloud identities; writes aggregate JSON |
| [Azure Terraform inventory](../terraform/azure-foundation/main.tf) | Ubuntu | Terraform, provider initialization, Azure authentication | Reads existing subscription/resource group; displays outputs |

Azure resource Reader alone does not establish Microsoft Graph directory-read permissions. Verify the signed-in tenant and granted directory permissions rather than granting broad administration to resolve an inventory error.

## Preview existing AD provisioning

Review source before using these lab-specific scripts. The administrative-identity script can grant Domain Admin through group nesting. Sample contractor/seasonal expiration dates are hard-coded to the 2026 scenario and need review before reuse.

On a Windows host with the AD module, in the directory containing the scripts:

```powershell
.\New-HVOrganizationalStructure.ps1 -WhatIf
.\New-HVAccessGroups.ps1 -WhatIf
.\New-HVAdministrativeIdentities.ps1 -WhatIf
.\New-HVSampleIdentities.ps1 -WhatIf
```

The previews inspect prerequisites and describe intended actions. Some scripts use a custom early-return preview; these are not full production transaction/rollback engines. Existing objects are checked, but that does not prove all configuration drift is reconciled.

## AD inventory

On HV-DC01, after reviewing and transferring the script:

```powershell
& "C:\Lab\Get-HVADInventory.ps1" -OutputPath "C:\Lab\HV-AD-Inventory.json"
Get-Item "C:\Lab\HV-AD-Inventory.json" | Select-Object Name, Length, LastWriteTime
```

Observed counts were 8 users, 64 groups and 4 computers. These include built-in objects. The JSON contains names, UPNs, distinguished names, departments and other directory metadata; it is not a sanitized public artifact.

The script reads the whole domain, uses approximate LastLogonDate information, and overwrites the supplied report path. Current collection/path edge cases are documented in [Phase 5 evidence](phase-5-automation-evidence.md).

## Entra inventory

From the repository root on Ubuntu:

```bash
az account show --query '{subscription:name,tenant:tenantId}' --output table
python3 python/Get-HVEntraInventory.py --output /tmp/HV-Entra-Inventory.json
```

Use an existing authorized CLI session; if expired, authenticate interactively before running. The script invokes Azure CLI's Microsoft Graph-backed user/group commands and records aggregate counts plus tenant/subscription metadata.

Known limitation: the initial enabled-user calculation treats missing accountEnabled values as not enabled. Default API projections may omit that field. Validate or correct the projection before relying on this count; the repository does not publish an unverified enabled-user total. Subprocess failures are not yet presented with a friendly diagnostic, and custom output directories must already exist.

## Terraform discovery

From the repository root on Ubuntu:

```bash
cd terraform/azure-foundation
terraform init
terraform fmt -check
terraform validate
export ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
terraform plan
```

The explicit subscription selection is required by the AzureRM 4.x configuration. Confirm the CLI context first. This configuration declares data sources and outputs, not managed resources. It explicitly disables automatic resource-provider registration. A successful plan can show new output values without infrastructure actions.

An apply is not required for this inventory exercise. Applying an output-only plan would persist local state, which must stay outside Git. Commit the provider lock file, not the provider cache, plans, state or credentials.

## Transfer and evidence

Transfer only reviewed scripts to the intended host. A temporary HTTP server was used for the initial AD script after a raw GitHub URL failed; the server was stopped afterward. The screenshot of that failed URL omitted the hyphen in Get-HVADInventory.ps1, so the 404 alone did not establish repository visibility.

Future transfers should verify file identity/hash and use an authenticated channel where available. Keep the full reports local and record aggregate outcomes in [metrics](../metrics/README.md).

## Source references

- [Microsoft Graph user properties](https://learn.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0): properties have explicit return/projection rules.
- [List users](https://learn.microsoft.com/en-us/graph/api/user-list?view=graph-rest-1.0): request the required property set and validate paging.
- [AzureRM provider configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs): provider registration behavior and authentication settings.

## Remaining reproducibility work

The GPOs, file share and sync registration were implemented interactively and are documented, but are not fully deployed by committed automation. Lifecycle input validation, repeat-run behavior, error reporting, report-field tests and timing measurements remain Phase 5 work.
