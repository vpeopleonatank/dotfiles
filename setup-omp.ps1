[CmdletBinding()]
param(
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repoDirectory = (Resolve-Path (Join-Path $PSScriptRoot 'omp/agent')).Path
$agentDirectory = if ($env:OMP_AGENT_DIR) { $env:OMP_AGENT_DIR } else { Join-Path $env:USERPROFILE '.omp\agent' }

function Test-LinkToRepo([string]$Path, [string]$Source) {
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  $item = Get-Item -LiteralPath $Path -Force
  if (-not $item.Target) { return $false }
  return ([System.IO.Path]::GetFullPath([string]$item.Target) -eq $Source)
}

foreach ($fileName in @('models.yml', 'config.yml')) {
  $sourcePath = Join-Path $repoDirectory $fileName
  $targetPath = Join-Path $agentDirectory $fileName

  if (Test-LinkToRepo $targetPath $sourcePath) {
    Write-Output "Already linked: $targetPath"
  } elseif (Test-Path -LiteralPath $targetPath) {
    throw "Conflict: existing OMP configuration retained: $targetPath"
  } elseif ($DryRun) {
    Write-Output "Would link $targetPath -> $sourcePath"
  } else {
    New-Item -ItemType Directory -Force -Path $agentDirectory | Out-Null
    New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath | Out-Null
    Write-Output "Linked $targetPath -> $sourcePath"
  }
}
