[CmdletBinding()]
param(
  [switch]$InstallPlugins,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repoConfig = (Resolve-Path (Join-Path $PSScriptRoot 'psmux/config.psmux')).Path
$configPath = Join-Path $HOME '.psmux.conf'
$ppmPath = Join-Path $HOME '.psmux/plugins/ppm'

function Test-LinkToRepo {
  if (-not (Test-Path -LiteralPath $configPath)) { return $false }
  $item = Get-Item -LiteralPath $configPath -Force
  if (-not $item.Target) { return $false }
  return ([System.IO.Path]::GetFullPath([string]$item.Target) -eq $repoConfig)
}

if (Test-LinkToRepo) {
  Write-Output "Already linked: $configPath"
} elseif (Test-Path -LiteralPath $configPath) {
  throw "Conflict: existing psmux config retained: $configPath"
} elseif ($DryRun) {
  Write-Output "Would link $configPath -> $repoConfig"
} else {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $configPath) | Out-Null
  New-Item -ItemType SymbolicLink -Path $configPath -Target $repoConfig | Out-Null
  Write-Output "Linked $configPath -> $repoConfig"
}

if ($InstallPlugins) {
  if (Test-Path -LiteralPath $ppmPath) {
    Write-Output "psmux PPM already exists: $ppmPath"
  } elseif ($DryRun) {
    Write-Output "Would clone psmux PPM into $ppmPath"
  } else {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ppmPath) | Out-Null
    $temporaryRepo = Join-Path ([System.IO.Path]::GetTempPath()) ("psmux-plugins-" + [guid]::NewGuid().ToString('N'))
    try {
      git clone --depth 1 https://github.com/psmux/psmux-plugins $temporaryRepo
      if ($LASTEXITCODE -ne 0) { throw "git clone failed with exit code $LASTEXITCODE" }
      Copy-Item -Recurse -LiteralPath (Join-Path $temporaryRepo 'ppm') -Destination $ppmPath
      Write-Output "Installed psmux PPM: $ppmPath"
    } finally {
      if (Test-Path -LiteralPath $temporaryRepo) {
        Remove-Item -Recurse -Force -LiteralPath $temporaryRepo
      }
    }
  }
}
