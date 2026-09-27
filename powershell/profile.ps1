# Cross-platform command shortcuts for PowerShell.

Set-Alias -Scope Global -Name g -Value git
Set-Alias -Scope Global -Name lg -Value lazygit
Set-Alias -Scope Global -Name t -Value psmux
Set-Alias -Scope Global -Name v -Value vim
Set-Alias -Scope Global -Name jl -Value jupyter-lab
Set-Alias -Scope Global -Name lzd -Value lazydocker

# `nv` is a built-in read-only alias for New-Variable, so use a function to
# provide the cross-platform Neovim shortcut without preventing profile load.
function global:nv {
  & nvim $args
}

function global:vimdiff {
  & nvim -d $args
}

function global:ez {
  $editor = if ($env:EDITOR) { $env:EDITOR } elseif (Get-Command nvim -ErrorAction SilentlyContinue) { 'nvim' } elseif (Get-Command vim -ErrorAction SilentlyContinue) { 'vim' } else { 'notepad' }
  & $editor $PROFILE
}

function global:lsh {
  . $PROFILE
}

function global:dcl {
  & docker compose logs -f -t --tail=100 @args
}

function global:downsub {
  & yt-dlp --sub-lang en --write-auto-sub --sub-format srt --skip-download @args
}

function global:downplaylistbest {
  & yt-dlp -f best -ci @args
}
