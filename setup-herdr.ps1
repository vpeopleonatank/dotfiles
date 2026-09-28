[CmdletBinding()]
param(
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repoConfig = (Resolve-Path (Join-Path $PSScriptRoot 'herdr/config.toml')).Path
$configRoot = Join-Path $env:APPDATA 'herdr'
$configPath = Join-Path $configRoot 'config.toml'

function Test-LinkToRepo {
  if (-not (Test-Path -LiteralPath $configPath)) { return $false }
  $item = Get-Item -LiteralPath $configPath -Force
  if (-not $item.Target) { return $false }
  return ([System.IO.Path]::GetFullPath([string]$item.Target) -eq $repoConfig)
}

if (Test-LinkToRepo) {
  Write-Output "Already linked: $configPath"
} elseif (Test-Path -LiteralPath $configPath) {
  throw "Conflict: existing Herdr config retained: $configPath"
} elseif ($DryRun) {
  Write-Output "Would link $configPath -> $repoConfig"
} else {
  New-Item -ItemType Directory -Force -Path $configRoot | Out-Null
  New-Item -ItemType SymbolicLink -Path $configPath -Target $repoConfig | Out-Null
  Write-Output "Linked $configPath -> $repoConfig"
}
