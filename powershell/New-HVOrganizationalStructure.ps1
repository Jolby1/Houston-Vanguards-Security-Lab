#requires -Version 5.1
#requires -Modules ActiveDirectory

[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

$domain = Get-ADDomain
$domainDN = $domain.DistinguishedName
$rootDN = "OU=Houston Vanguards,$domainDN"

$organizationalUnits = @(
    @{
        Name = "Houston Vanguards"
        Path = $domainDN
        Description = "Root OU for Houston Vanguards managed objects"
    }
    @{
        Name = "Identities"
        Path = $rootDN
        Description = "Standard human identities"
    }
    @{
        Name = "Employees"
        Path = "OU=Identities,$rootDN"
        Description = "Active employee identities"
    }
    @{
        Name = "Contractors"
        Path = "OU=Identities,$rootDN"
        Description = "Active contractor identities"
    }
    @{
        Name = "Seasonal"
        Path = "OU=Identities,$rootDN"
        Description = "Seasonal workforce identities"
    }
    @{
        Name = "Vendors"
        Path = "OU=Identities,$rootDN"
        Description = "External vendor identities"
    }
    @{
        Name = "Disabled"
        Path = "OU=Identities,$rootDN"
        Description = "Disabled identities pending retention or deletion"
    }
    @{
        Name = "Privileged Identities"
        Path = $rootDN
        Description = "Separate administrative identities"
    }
    @{
        Name = "Tier 0"
        Path = "OU=Privileged Identities,$rootDN"
        Description = "Identity-control-plane administrators"
    }
    @{
        Name = "Tier 1"
        Path = "OU=Privileged Identities,$rootDN"
        Description = "Server and application administrators"
    }
    @{
        Name = "Tier 2"
        Path = "OU=Privileged Identities,$rootDN"
        Description = "Workstation and help-desk administrators"
    }
    @{
        Name = "Service Accounts"
        Path = $rootDN
        Description = "Non-human Active Directory identities"
    }
    @{
        Name = "Managed"
        Path = "OU=Service Accounts,$rootDN"
        Description = "Managed service identities"
    }
    @{
        Name = "Legacy"
        Path = "OU=Service Accounts,$rootDN"
        Description = "Legacy service accounts requiring manual governance"
    }
    @{
        Name = "Devices"
        Path = $rootDN
        Description = "Domain-joined devices"
    }
    @{
        Name = "Servers"
        Path = "OU=Devices,$rootDN"
        Description = "Member servers"
    }
    @{
        Name = "Workstations"
        Path = "OU=Devices,$rootDN"
        Description = "User workstations"
    }
    @{
        Name = "Groups"
        Path = $rootDN
        Description = "Authorization and membership groups"
    }
    @{
        Name = "Departments"
        Path = "OU=Groups,$rootDN"
        Description = "Department membership groups"
    }
    @{
        Name = "Roles"
        Path = "OU=Groups,$rootDN"
        Description = "Business and administrative role groups"
    }
    @{
        Name = "Resources"
        Path = "OU=Groups,$rootDN"
        Description = "Resource permission groups"
    }
)

foreach ($ou in $organizationalUnits) {
    $ouDN = "OU=$($ou.Name),$($ou.Path)"
    $existingOU = Get-ADOrganizationalUnit `
        -Identity $ouDN `
        -ErrorAction SilentlyContinue

    if ($null -ne $existingOU) {
        Write-Host "EXISTS: $ouDN" -ForegroundColor Yellow
        continue
    }

    if ($PSCmdlet.ShouldProcess($ouDN, "Create organizational unit")) {
        New-ADOrganizationalUnit `
            -Name $ou.Name `
            -Path $ou.Path `
            -Description $ou.Description `
            -ProtectedFromAccidentalDeletion $true

        Write-Host "CREATED: $ouDN" -ForegroundColor Green
    }
}

$rootOU = Get-ADOrganizationalUnit `
    -Identity $rootDN `
    -ErrorAction SilentlyContinue

if ($null -ne $rootOU) {
    Write-Host "`nCurrent Houston Vanguards OU structure:" -ForegroundColor Cyan

    Get-ADOrganizationalUnit `
        -Filter * `
        -SearchBase $rootDN `
        -SearchScope Subtree |
        Sort-Object DistinguishedName |
        Select-Object Name, DistinguishedName
}
