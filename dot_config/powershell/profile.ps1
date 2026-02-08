# VI mode
Set-PSReadLineOption -EditMode Vi

# Bind Ctrl+p and Ctrl+n to history navigation
Set-PSReadLineKeyHandler -Key "Ctrl+p" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function HistorySearchForward

# Aliases
Set-Alias -Name ls -Value eza
Set-Alias -Name vim -Value nvim

# Starship
Invoke-Expression (&starship init powershell)