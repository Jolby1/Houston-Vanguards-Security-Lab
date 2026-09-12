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

$standardUserPath = "OU=Employees,OU=Identities,OU=Houston Vanguards,$baseDN"
$tierZeroPath = "OU=Tier 0,OU=Privileged Identities,OU=Houston Vanguards,$baseDN"
$groupPath = "OU=Roles,OU=Groups,OU=Houston Vanguards,$baseDN"

$requiredOUs = @(
    $standardUserPath
    $tierZeroPath
    $groupPath
)

foreach ($ou in $requiredOUs) {
    try {
        Get-ADOrganizationalUnit -Identity $ou -ErrorAction Stop | Out-Null
    }
    catch {
        throw "Required OU does not exist: $ou"
    }
}

if ($WhatIfPreference) {
    Write-Host "PREVIEW: Create standard account jrodriguez in $standardUserPath"
    Write-Host "PREVIEW: Create Tier 0 account adm0-jrodriguez in $tierZeroPath"
    Write-Host "PREVIEW: Create role group GG-Priv-T0-ADAdmins in $groupPath"
    Write-Host "PREVIEW: Add adm0-jrodriguez to GG-Priv-T0-ADAdmins"
    Write-Host "PREVIEW: Add GG-Priv-T0-ADAdmins to Domain Admins"
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

$standardUser = Get-HVUser -SamAccountName "jrodriguez"

if ($null -eq $standardUser) {
    $standardPassword = Read-Host `
        "Enter a temporary password for jrodriguez" `
        -AsSecureString

    if ($PSCmdlet.ShouldProcess("jrodriguez", "Create standard account")) {
        New-ADUser `
            -Name "Jolber Rodriguez" `
            -GivenName "Jolber" `
            -Surname "Rodriguez" `
            -DisplayName "Jolber Rodriguez" `
            -SamAccountName "jrodriguez" `
            -UserPrincipalName "jrodriguez@$expectedDomain" `
            -Path $standardUserPath `
            -AccountPassword $standardPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "CREATED: jrodriguez"
    }
}
else {
    Write-Host "EXISTS: jrodriguez"
}

$tierZeroUser = Get-HVUser -SamAccountName "adm0-jrodriguez"

if ($null -eq $tierZeroUser) {
    $tierZeroPassword = Read-Host `
        "Enter a different temporary password for adm0-jrodriguez" `
        -AsSecureString

    if ($PSCmdlet.ShouldProcess("adm0-jrodriguez", "Create Tier 0 account")) {
        New-ADUser `
            -Name "Jolber Rodriguez (Tier 0)" `
            -GivenName "Jolber" `
            -Surname "Rodriguez" `
            -DisplayName "Jolber Rodriguez (Tier 0)" `
            -Description "Dedicated Tier 0 Active Directory administrative account" `
            -SamAccountName "adm0-jrodriguez" `
            -UserPrincipalName "adm0-jrodriguez@$expectedDomain" `
            -Path $tierZeroPath `
            -AccountPassword $tierZeroPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "CREATED: adm0-jrodriguez"
    }
}
else {
    Write-Host "EXISTS: adm0-jrodriguez"
}

$roleGroupName = "GG-Priv-T0-ADAdmins"

try {
    $roleGroup = Get-ADGroup -Identity $roleGroupName -ErrorAction Stop
    Write-Host "EXISTS: $roleGroupName"
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    if ($PSCmdlet.ShouldProcess($roleGroupName, "Create Tier 0 role group")) {
        $roleGroup = New-ADGroup `
            -Name $roleGroupName `
            -SamAccountName $roleGroupName `
            -GroupCategory Security `
            -GroupScope Global `
            -Path $groupPath `
            -Description "Tier 0 administrators authorized to administer Active Directory" `
            -PassThru

        Write-Host "CREATED: $roleGroupName"
    }
}

$tierZeroUser = Get-ADUser -Identity "adm0-jrodriguez"
$roleGroup = Get-ADGroup -Identity $roleGroupName

$tierZeroIsMember = Get-ADGroupMember -Identity $roleGroup |
    Where-Object { $_.SID -eq $tierZeroUser.SID }

if ($null -eq $tierZeroIsMember) {
    if ($PSCmdlet.ShouldProcess(
        $roleGroupName,
        "Add adm0-jrodriguez as a member"
    )) {
        Add-ADGroupMember `
            -Identity $roleGroup `
            -Members $tierZeroUser

        Write-Host "ADDED: adm0-jrodriguez -> $roleGroupName"
    }
}
else {
    Write-Host "MEMBERSHIP EXISTS: adm0-jrodriguez -> $roleGroupName"
}

$domainAdminsSID = "$($domain.DomainSID)-512"
$domainAdmins = Get-ADGroup -Identity $domainAdminsSID

$roleGroupIsMember = Get-ADGroupMember -Identity $domainAdmins |
    Where-Object { $_.SID -eq $roleGroup.SID }

if ($null -eq $roleGroupIsMember) {
    if ($PSCmdlet.ShouldProcess(
        $domainAdmins.Name,
        "Add $roleGroupName as a member"
    )) {
        Add-ADGroupMember `
            -Identity $domainAdmins `
            -Members $roleGroup

        Write-Host "ADDED: $roleGroupName -> $($domainAdmins.Name)"
    }
}
else {
    Write-Host "MEMBERSHIP EXISTS: $roleGroupName -> $($domainAdmins.Name)"
}

Write-Host ""
Write-Host "Administrative identity configuration completed."
Write-Host "Both users must change their temporary password at first sign-in."
