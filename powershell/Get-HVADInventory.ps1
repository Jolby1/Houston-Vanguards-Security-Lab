[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "C:\Lab\HV-AD-Inventory.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

$users = Get-ADUser -Filter * -Properties Enabled, Department, Title, LastLogonDate |
    Select-Object Name, SamAccountName, UserPrincipalName, Enabled,
        Department, Title, LastLogonDate, DistinguishedName

$groups = Get-ADGroup -Filter * |
    Select-Object Name, SamAccountName, GroupScope, GroupCategory,
        DistinguishedName

$computers = Get-ADComputer -Filter * -Properties OperatingSystem, Enabled |
    Select-Object Name, DNSHostName, OperatingSystem, Enabled,
        DistinguishedName

$report = [ordered]@{
    GeneratedAt = (Get-Date).ToUniversalTime().ToString("o")
    Domain      = (Get-ADDomain).DNSRoot
    Users       = $users
    Groups      = $groups
    Computers   = $computers
}

$parent = Split-Path -Parent $OutputPath

if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

$report |
    ConvertTo-Json -Depth 6 |
    Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "Inventory written to $OutputPath"
Write-Host "Users: $($users.Count)"
Write-Host "Groups: $($groups.Count)"
Write-Host "Computers: $($computers.Count)"
