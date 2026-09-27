[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot 'nvim')).Path
$configRoot = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'nvim' } else { Join-Path $HOME 'AppData\Local\nvim' }

if (Test-Path -LiteralPath $configRoot) {
  $item = Get-Item -LiteralPath $configRoot -Force
  $linkTarget = if ($item.Target) { [System.IO.Path]::GetFullPath([string]$item.Target) } else { $null }
  if ($linkTarget -eq $repo) {
    Write-Output "Already linked: $configRoot"
    exit 0
  }
  Write-Error "Conflict: existing Neovim config retained: $configRoot"
}

if ($DryRun) {
  Write-Output "Would link $configRoot -> $repo"
  exit 0
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $configRoot) | Out-Null
New-Item -ItemType Junction -Path $configRoot -Target $repo | Out-Null
Write-Output "Linked $configRoot -> $repo"
