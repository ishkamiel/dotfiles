<#
SPDX-License-Identifier: MIT
Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#>
{{ template "windows/logger.ps1" . }}

function Test-WingetInstalled {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Id
    )
    $result = winget list --id $Id --exact 2>$null
    if ($result -match $Id) {
        return $true
    }
    return $false
}

function Test-WingetAvailable {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Id
    )
    $result = winget search --id $Id --exact 2>$null
    if ($result -match $Id) {
        return $true
    }
    return $false
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [switch]$Optional
    )

    if (Test-WingetInstalled -Id $Id) {
        Write-Host "Found $Id (winget)"
        return
    }

    if (-not (Test-WingetAvailable -Id $Id)) {
        if (-not $Optional) {
            Write-ErrorLog "Cannot find pkg to install: $Id (winget)"
        }
        return
    }

    Write-Host "Installing $Id (winget)"
    winget install --id $Id --source winget --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0 -and -not $Optional) {
        Write-ErrorLog "Failed to install: $Id (winget)"
    }
}

function Install-WingetPackageList {
    param(
        [string[]]$Ids,
        [switch]$Optional
    )

    foreach ($pkg in $Ids) {
        Install-WingetPackage -Id $pkg -Optional:$Optional
    }
}

# vim: set filetype=ps1:
