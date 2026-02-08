<#
SPDX-License-Identifier: MIT
Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#>

if (-not $global:ISH_CHEZMOI_LOGGER_INIT) {

$script:ChezmoiErrorLog = Join-Path $HOME ".chezmoi_error.log"
    
function Write-ErrorLog {
    param([string]$Message)
    "[!!]: $Message" | Tee-Object -FilePath $script:ChezmoiErrorLog -Append
}

function Open-Logger {
    if (Test-Path $script:ChezmoiErrorLog) {
        Remove-Item $script:ChezmoiErrorLog -Force -ErrorAction SilentlyContinue
    }
}

function Close-Logger {
    if (Test-Path $script:ChezmoiErrorLog) {
        Write-Host ""
        Write-Host ""
        Write-Host "Encountered errors:"
        Write-Host ""
        Get-Content $script:ChezmoiErrorLog
        Remove-Item $script:ChezmoiErrorLog -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "All ok"
    }
}

# Set the guard to true
$global:ISH_CHEZMOI_LOGGER_INIT = $true
}
