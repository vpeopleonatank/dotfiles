[CmdletBinding()]
param(
  [string]$ProfilePath = $PROFILE.CurrentUserCurrentHost,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$profileSource = (Resolve-Path (Join-Path $PSScriptRoot 'powershell/profile.ps1')).Path
$startMarker = '# >>> dotfiles managed PowerShell >>>'
$endMarker = '# <<< dotfiles managed PowerShell <<<'
$sourceLine = ". '$($profileSource.Replace("'", "''"))'"

if (Test-Path -LiteralPath $ProfilePath) {
  $existing = Get-Content -LiteralPath $ProfilePath -Raw
} else {
  $existing = ''
}

$startCount = [regex]::Matches($existing, [regex]::Escape($startMarker)).Count
$endCount = [regex]::Matches($existing, [regex]::Escape($endMarker)).Count
if ($startCount -ne $endCount -or $startCount -gt 1) {
  throw "Malformed managed PowerShell profile block in $ProfilePath"
}

$managedBlock = @"
$startMarker
$sourceLine
$endMarker
"@

if ($startCount -eq 1) {
  $updated = [regex]::Replace(
    $existing,
    "(?s)$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))",
    $managedBlock
  )
} elseif ([string]::IsNullOrWhiteSpace($existing)) {
  $updated = "$managedBlock`n"
} else {
  $updated = "$($existing.TrimEnd())`n`n$managedBlock`n"
}

if ($updated -ceq $existing) {
  Write-Output "Already configured: $ProfilePath"
} elseif ($DryRun) {
  Write-Output "Would update PowerShell profile: $ProfilePath"
} else {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ProfilePath) | Out-Null
  Set-Content -LiteralPath $ProfilePath -Value $updated -Encoding utf8
  Write-Output "Updated PowerShell profile: $ProfilePath"
}
