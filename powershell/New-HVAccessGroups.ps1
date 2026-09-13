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
$departmentPath = "OU=Departments,OU=Groups,OU=Houston Vanguards,$baseDN"
$resourcePath = "OU=Resources,OU=Groups,OU=Houston Vanguards,$baseDN"

foreach ($ou in @($departmentPath, $resourcePath)) {
    try {
        Get-ADOrganizationalUnit -Identity $ou -ErrorAction Stop | Out-Null
    }
    catch {
        throw "Required OU does not exist: $ou"
    }
}

$groups = @(
    @{
        Name        = "GG-Dept-IT"
        Scope       = "Global"
        Path        = $departmentPath
        Description = "Houston Vanguards Information Technology department"
    }
    @{
        Name        = "GG-Dept-HR"
        Scope       = "Global"
        Path        = $departmentPath
        Description = "Houston Vanguards Human Resources department"
    }
    @{
        Name        = "GG-Dept-Finance"
        Scope       = "Global"
        Path        = $departmentPath
        Description = "Houston Vanguards Finance department"
    }
    @{
        Name        = "GG-Dept-BaseballOperations"
        Scope       = "Global"
        Path        = $departmentPath
        Description = "Houston Vanguards Baseball Operations department"
    }
    @{
        Name        = "GG-Dept-StadiumOperations"
        Scope       = "Global"
        Path        = $departmentPath
        Description = "Houston Vanguards Stadium Operations department"
    }
    @{
        Name        = "GG-Dept-Ticketing"
        Scope       = "Global"
        Path        = $departmentPath
        Description = "Houston Vanguards Ticketing department"
    }
    @{
        Name        = "GG-Dept-Marketing"
        Scope       = "Global"
        Path        = $departmentPath
        Description = "Houston Vanguards Marketing department"
    }
    @{
        Name        = "DL-FS-IT-Shared-RO"
        Scope       = "DomainLocal"
        Path        = $resourcePath
        Description = "Read-only access to the IT shared folder"
    }
    @{
        Name        = "DL-FS-IT-Shared-RW"
        Scope       = "DomainLocal"
        Path        = $resourcePath
        Description = "Read/write access to the IT shared folder"
    }
)

if ($WhatIfPreference) {
    foreach ($group in $groups) {
        Write-Host "PREVIEW: Create or verify $($group.Name)"
    }

    Write-Host "PREVIEW: Add jrodriguez to GG-Dept-IT"
    Write-Host "PREVIEW: Add GG-Dept-IT to DL-FS-IT-Shared-RW"
    Write-Host "No changes were made."
    return
}

function Get-HVGroup {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        Get-ADGroup -Identity $Name -ErrorAction Stop
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        $null
    }
}

foreach ($group in $groups) {
    $existingGroup = Get-HVGroup -Name $group.Name

    if ($null -eq $existingGroup) {
        if ($PSCmdlet.ShouldProcess($group.Name, "Create security group")) {
            New-ADGroup `
                -Name $group.Name `
                -SamAccountName $group.Name `
                -GroupCategory Security `
                -GroupScope $group.Scope `
                -Path $group.Path `
                -Description $group.Description

            Write-Host "CREATED: $($group.Name)"
        }
    }
    else {
        Write-Host "EXISTS: $($group.Name)"
    }
}

function Add-HVGroupMember {
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(Mandatory)]
        [string]$MemberName
    )

    $targetGroup = Get-ADGroup -Identity $GroupName
    $member = Get-ADObject -LDAPFilter "(sAMAccountName=$MemberName)"

    if ($null -eq $member) {
        throw "Required member does not exist: $MemberName"
    }

    $existingMember = Get-ADGroupMember -Identity $targetGroup |
        Where-Object DistinguishedName -eq $member.DistinguishedName

    if ($null -eq $existingMember) {
        if ($PSCmdlet.ShouldProcess(
            "$MemberName -> $GroupName",
            "Add group membership"
        )) {
            Add-ADGroupMember -Identity $targetGroup -Members $member
            Write-Host "ADDED: $MemberName -> $GroupName"
        }
    }
    else {
        Write-Host "MEMBERSHIP EXISTS: $MemberName -> $GroupName"
    }
}

Add-HVGroupMember `
    -GroupName "GG-Dept-IT" `
    -MemberName "jrodriguez"

Add-HVGroupMember `
    -GroupName "DL-FS-IT-Shared-RW" `
    -MemberName "GG-Dept-IT"

Write-Host "AGDLP group configuration completed."
