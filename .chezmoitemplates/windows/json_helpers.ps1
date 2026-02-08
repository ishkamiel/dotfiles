<#
SPDX-License-Identifier: MIT
Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#>

if (-not $global:ISH_CHEZMOI_JSON_HELPER_INIT) {

function Merge-WindowsTerminalJSON ($target, $source) {
    if ($null -eq $target -or $null -eq $source) { return }
    foreach ($property in $source.PSObject.Properties) {
        $name = $property.Name
        $value = $property.Value

        # If the property is "profiles", we need special handling to avoid overwriting the "list"
        if ($name -eq "profiles") {
            if (-not $target.profiles) { $target | Add-Member -MemberType NoteProperty -Name "profiles" -Value ([PSCustomObject]@{}) }
            
            # Merge "defaults" inside profiles specifically
            if ($value.defaults) {
                if (-not $target.profiles.defaults) { $target.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{}) }
                Merge-WindowsTerminalJSON -target $target.profiles.defaults -source $value.defaults
            }
            # Machine-specific profiles in "list" are preserved and not modified by this merge operation.
            foreach ($cur_profile in $value.list) {
                Write-Output "Checking one"
                if ($cur_profile.commandline -and $cur_profile.commandline -match '\\powershell\.exe$') {
                    Write-Output "Found one"
                    $cur_profile.commandline = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
                }
            }
        }
        # If it's a regular value (string, int, bool), just overwrite/set it
        elseif ($value -isnot [System.Management.Automation.PSCustomObject]) {
            if ($null -ne $target.PSObject -and $target.PSObject.Properties.Match($name).Count) {
                $target.$name = $value
            } else {
                $target | Add-Member -MemberType NoteProperty -Name $name -Value $value
            }
        }
        # If it's a nested object (and not profiles), recurse (Optional, usually not needed for WT root)
        else {
             if ($null -eq $target.PSObject -or -not $target.PSObject.Properties.Match($name).Count) {
                $target | Add-Member -MemberType NoteProperty -Name $name -Value $value
             } else {
                Merge-WindowsTerminalJSON -target $target.$name -source $value
             }
        }
    }

    # Switch all PowerShells to the pwsh 7
    foreach ($cur_profile in $target.profiles.list) {
        if ($cur_profile.commandline -match 'powershell\.exe$') {
            $cur_profile.commandline = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
        }
    }
}

$global:ISH_CHEZMOI_JSON_HELPER_INIT = $true
}