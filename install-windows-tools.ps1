[CmdletBinding()]
param(
  [switch]$SkipVisualStudio,
  [switch]$SkipNeovim
)

$ErrorActionPreference = 'Stop'

function Install-WingetPackage {
  param(
    [Parameter(Mandatory)] [string]$Id,
    [Parameter(Mandatory)] [string]$Name,
    [string[]]$ExtraArguments = @()
  )

  Write-Host "Installing $Name ($Id)..."
  & winget install --id $Id --exact --source winget `
    --accept-source-agreements --accept-package-agreements @ExtraArguments

  if ($LASTEXITCODE -notin @(0, 3010)) {
    throw "winget failed to install $Name (exit code $LASTEXITCODE)."
  }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw 'winget was not found. Install App Installer from the Microsoft Store, then run this script again.'
}

# Core tools used by Neovim and common native plugins.
Install-WingetPackage -Id 'Git.Git' -Name 'Git'
Install-WingetPackage -Id 'BurntSushi.ripgrep.MSVC' -Name 'ripgrep'
Install-WingetPackage -Id 'sharkdp.fd' -Name 'fd'
Install-WingetPackage -Id '7zip.7zip' -Name '7-Zip'
Install-WingetPackage -Id 'Kitware.CMake' -Name 'CMake'
Install-WingetPackage -Id 'LLVM.LLVM' -Name 'LLVM/Clang'

if (-not $SkipVisualStudio) {
  $vsArguments = @(
    '--override',
    '--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'
  )
  Install-WingetPackage `
    -Id 'Microsoft.VisualStudio.2022.BuildTools' `
    -Name 'Visual Studio 2022 C++ Build Tools' `
    -ExtraArguments $vsArguments
}

if (-not $SkipNeovim) {
  Install-WingetPackage -Id 'Neovim.Neovim' -Name 'Neovim'
}

$llvmBin = 'C:\Program Files\LLVM\bin'
if (Test-Path (Join-Path $llvmBin 'clang.exe')) {
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  $pathEntries = @($userPath -split ';' | Where-Object { $_ })
  if ($pathEntries -notcontains $llvmBin) {
    [Environment]::SetEnvironmentVariable(
      'Path',
      (($pathEntries + $llvmBin) -join ';'),
      'User'
    )
    Write-Host "Added $llvmBin to the user PATH."
  }
}

Write-Host ''
Write-Host 'Installation complete.'
Write-Host 'Close and reopen PowerShell/Neovim so they load the updated PATH.'
Write-Host 'Verify with: clang --version; cmake --version; rg --version; nvim --version'
