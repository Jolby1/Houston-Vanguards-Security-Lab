#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory

[CmdletBinding(SupportsShouldProcess)]
param()

Import-Module ActiveDirectory

$domain = Get-ADDomain
$expectedDomain = "corp.hv-lab.test"

if ($domain.DNSRoot -ne $expectedDomain) {
    throw "Expected domain $expectedDomain but found $($domain.DNSRoot)."
}

$baseDN = $domain.DistinguishedName

$identities = @(
    @{
        Name           = "Maya Chen"
        GivenName      = "Maya"
        Surname        = "Chen"
        SamAccountName = "mchen"
        Type           = "Employee"
        Department     = "Finance"
        Title          = "Financial Analyst"
        Path           = "OU=Employees,OU=Identities,OU=Houston Vanguards,$baseDN"
        Group          = "GG-Dept-Finance"
        Expiration     = $null
    }
    @{
        Name           = "Daniel Brooks"
        GivenName      = "Daniel"
        Surname        = "Brooks"
        SamAccountName = "dbrooks.ext"
        Type           = "Contractor"
        Department     = "Information Technology"
        Title          = "Infrastructure Consultant"
        Path           = "OU=Contractors,OU=Identities,OU=Houston Vanguards,$baseDN"
        Group          = "GG-Dept-IT"
        Expiration     = [datetime]"2026-12-31 23:59:59"
    }
    @{
        Name           = "Sofia Martinez"
        GivenName      = "Sofia"
        Surname        = "Martinez"
        SamAccountName = "smartinez.sea"
        Type           = "Seasonal"
        Department     = "Ticketing"
        Title          = "Seasonal Ticketing Representative"
        Path           = "OU=Seasonal,OU=Identities,OU=Houston Vanguards,$baseDN"
        Group          = "GG-Dept-Ticketing"
        Expiration     = [datetime]"2026-11-30 23:59:59"
    }
)

foreach ($identity in $identities) {
    try {
        Get-ADOrganizationalUnit -Identity $identity.Path -ErrorAction Stop |
            Out-Null
    }
    catch {
        throw "Required OU does not exist: $($identity.Path)"
    }

    try {
        Get-ADGroup -Identity $identity.Group -ErrorAction Stop |
            Out-Null
    }
    catch {
        throw "Required group does not exist: $($identity.Group)"
    }
}

if ($WhatIfPreference) {
    foreach ($identity in $identities) {
        $expirationText = if ($null -eq $identity.Expiration) {
            "No expiration"
        }
        else {
            $identity.Expiration.ToString("yyyy-MM-dd")
        }

        Write-Host (
            "PREVIEW: Create or verify {0} ({1}); group={2}; expiration={3}" -f
            $identity.SamAccountName,
            $identity.Type,
            $identity.Group,
            $expirationText
        )
    }

    Write-Host "No changes were made."
    return
}

function Get-HVUser {
    param(
        [Parameter(Mandatory)]
        [string]$SamAccountName
    )

    try {
        Get-ADUser -Identity $SamAccountName -ErrorAction Stop
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        $null
    }
}

foreach ($identity in $identities) {
    $user = Get-HVUser -SamAccountName $identity.SamAccountName

    if ($null -eq $user) {
        $temporaryPassword = Read-Host `
            "Enter a unique temporary password for $($identity.SamAccountName)" `
            -AsSecureString

        $newUserParameters = @{
            Name                  = $identity.Name
            GivenName             = $identity.GivenName
            Surname               = $identity.Surname
            DisplayName           = $identity.Name
            SamAccountName        = $identity.SamAccountName
            UserPrincipalName     = "$($identity.SamAccountName)@$expectedDomain"
            Path                  = $identity.Path
            Department            = $identity.Department
            Title                 = $identity.Title
            Company               = "Houston Vanguards"
            Description           = "$($identity.Type) - $($identity.Title)"
            AccountPassword       = $temporaryPassword
            Enabled               = $true
            ChangePasswordAtLogon = $true
        }

        if ($null -ne $identity.Expiration) {
            $newUserParameters.AccountExpirationDate = $identity.Expiration
        }

        if ($PSCmdlet.ShouldProcess(
            $identity.SamAccountName,
            "Create $($identity.Type) account"
        )) {
            New-ADUser @newUserParameters
            Write-Host "CREATED: $($identity.SamAccountName)"
        }
    }
    else {
        Write-Host "EXISTS: $($identity.SamAccountName)"
    }

    $user = Get-ADUser -Identity $identity.SamAccountName
    $group = Get-ADGroup -Identity $identity.Group

    $membershipExists = Get-ADGroupMember -Identity $group |
        Where-Object DistinguishedName -eq $user.DistinguishedName

    if ($null -eq $membershipExists) {
        if ($PSCmdlet.ShouldProcess(
            "$($identity.SamAccountName) -> $($identity.Group)",
            "Add department membership"
        )) {
            Add-ADGroupMember -Identity $group -Members $user

            Write-Host (
                "ADDED: {0} -> {1}" -f
                $identity.SamAccountName,
                $identity.Group
            )
        }
    }
    else {
        Write-Host (
            "MEMBERSHIP EXISTS: {0} -> {1}" -f
            $identity.SamAccountName,
            $identity.Group
        )
    }
}

Write-Host "Sample identity configuration completed."
