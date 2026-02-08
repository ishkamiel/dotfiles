<#
SPDX-License-Identifier: MIT
Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#>

$script:ChezmoiErrorLog = if ($env:CHEZMOI_ERROR_LOG) { $env:CHEZMOI_ERROR_LOG } else { Join-Path $HOME ".chezmoi_error.log" }
$env:CHEZMOI_ERROR_LOG = $script:ChezmoiErrorLog

function Write-ErrorLog {
    param([string]$Message)
    "[!!]: $Message" | Tee-Object -FilePath $script:ChezmoiErrorLog -Append
}

function Test-WingetInstalled {
    param([string]$Id)
    $output = winget list --id $Id --source winget --accept-source-agreements --accept-package-agreements 2>$null
    return ($LASTEXITCODE -eq 0 -and $output -match [regex]::Escape($Id))
}

function Test-WingetInstallable {
    param([string]$Id)
    winget show --id $Id --source winget --accept-source-agreements --accept-package-agreements >$null 2>&1
    return ($LASTEXITCODE -eq 0)
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

    if (-not (Test-WingetInstallable -Id $Id)) {
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
