# Phase 5 — Automation Evidence and Open Work

Status: in progress. Updated October 5, 2026.

## Implemented deliverables

| Deliverable | Evidence | Current boundary |
|---|---|---|
| Terraform Azure inventory | Existing subscription/resource group read successfully; output-only plan; formatting and validation reported passed | No infrastructure managed or deployed by Terraform |
| PowerShell AD inventory | JSON report generated on HV-DC01; console showed 8 users, 64 groups and 4 computers | Whole-directory snapshot includes built-in objects; report contains identity data |
| Python Entra inventory | Script published and run reported by operator | Counts were not supplied; original enabled-user count needs property-coverage validation |

Tool versions recorded during setup: PowerShell 7.6.5, Python 3.12.3, Azure CLI 2.90.0 and Terraform 1.16.5 on Linux. These describe the operator's environment, not recommended latest versions.

## What the code demonstrates

- PowerShell queries AD users, groups and computers and serializes a local JSON inventory.
- Python invokes Azure CLI, parses JSON, and builds an aggregate cloud report.
- Terraform uses AzureRM data sources to inspect existing infrastructure.
- Existing provisioning scripts contain `SupportsShouldProcess` / `-WhatIf` support and check for existing objects.

## Code-review findings

The initial Entra script relies on default Azure CLI user fields. Microsoft Graph does not return every user property by default. Missing `accountEnabled` values must not be interpreted as disabled users. Cloud counts remain unvalidated until that reporting path is corrected and compared with the source.

The AD inventory assumes multi-object collections and an output path with a parent directory. It worked for the recorded dataset; zero/single-object and relative-path behavior remain hardening tasks. It is read-only against AD but writes or overwrites the specified local report. `LastLogonDate` is approximate replicated logon information, not a complete activity audit.

AzureRM can automatically register resource providers when configuring the provider for operations such as planning. The inventory configuration now explicitly disables that behavior so discovery does not request provider registrations. This code-review adjustment requires no resource deployment.

## Repository checks — October 5, 2026

- All five PowerShell scripts passed parser-based syntax checks; no AD mutations were run during this review.
- The Python inventory script passed an AST syntax check. This does not validate its live API results.
- Terraform formatting and configuration validation passed after the provider-registration change. No new live plan or apply was run during the portfolio review.
- Local Markdown file links and fenced code blocks passed automated checks across 25 documents.

These repository checks supplement, rather than replace, the earlier environment execution results.

## Completion criteria still open

- Confirm cloud counts, requested properties and paging behavior.
- Add tests for missing properties, errors and report paths.
- Complete the planned PowerShell/Graph-specific inventory, or explicitly revise the issue scope.
- Implement a controlled identity lifecycle workflow and validate dry-run, execution, repeat-run and failure paths.
- Measure execution duration and a comparable manual baseline.
- Publish final Phase 5 results and learning notes before closing the issue.

No automation time-saving percentage or end-to-end lifecycle completion is claimed.

See the [automation guide](automation-guide.md) for execution instructions and limitations.
