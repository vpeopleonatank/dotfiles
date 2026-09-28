[CmdletBinding()]
param(
  [string]$BaseUrl = $(if ($env:OMP_CPA_GUI_BASE_URL) { $env:OMP_CPA_GUI_BASE_URL } else { 'http://127.0.0.1:8317/v1' }),
  [string]$ApiKeyEnvironment = $(if ($env:OMP_CPA_GUI_API_KEY_ENV) { $env:OMP_CPA_GUI_API_KEY_ENV } else { 'OMP_CPA_GUI_API_KEY' }),
  [switch]$SkipInstall,
  [switch]$Force,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$agentDirectory = if ($env:OMP_AGENT_DIR) { $env:OMP_AGENT_DIR } else { Join-Path $env:USERPROFILE '.omp\agent' }
$modelsPath = Join-Path $agentDirectory 'models.yml'
$configPath = Join-Path $agentDirectory 'config.yml'

foreach ($path in @($modelsPath, $configPath)) {
  if ((Test-Path -LiteralPath $path) -and -not $Force) {
    throw "Conflict: existing OMP configuration retained: $path (rerun with -Force to back up and replace it)"
  }
}

if (-not $SkipInstall -and -not (Get-Command omp -ErrorAction SilentlyContinue)) {
  if ($DryRun) {
    Write-Output 'Would install OMP from https://omp.sh/install.ps1'
  } else {
    Invoke-RestMethod https://omp.sh/install.ps1 | Invoke-Expression
  }
}

if ($DryRun) {
  Write-Output "Would write $modelsPath and $configPath for $BaseUrl"
  exit 0
}

New-Item -ItemType Directory -Force -Path $agentDirectory | Out-Null
$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
foreach ($path in @($modelsPath, $configPath)) {
  if (Test-Path -LiteralPath $path) {
    Move-Item -LiteralPath $path -Destination "$path.bak-$timestamp"
    Write-Output "Backed up $path"
  }
}

@"
providers:
  cpa-gui:
    baseUrl: $BaseUrl
    api: openai-responses
    apiKey: $ApiKeyEnvironment
    models:
      - id: gpt-5.6-luna
        reasoning: true
        input: [text, image]
        contextWindow: 272000
      - id: gpt-5.6-terra
        reasoning: true
        input: [text, image]
        contextWindow: 272000
      - id: gpt-5.6-sol
        reasoning: true
        input: [text, image]
        contextWindow: 272000
      - id: gpt-6-sol
        reasoning: true
        input: [text, image]
        contextWindow: 272000
      - id: gpt-6-astra
        reasoning: true
        input: [text, image]
        contextWindow: 272000
"@ | Set-Content -LiteralPath $modelsPath -Encoding utf8

@'
modelRoles:
  default: cpa-gui/gpt-5.6-terra:medium
  smol: cpa-gui/gpt-5.6-luna:medium
  slow: cpa-gui/gpt-6-sol:high
  vision: cpa-gui/gpt-6-sol:high
  plan: cpa-gui/gpt-6-sol:xhigh
  designer: cpa-gui/gpt-6-sol:high
  commit: cpa-gui/gpt-5.6-terra:medium
  tiny: cpa-gui/gpt-5.6-luna:low
  task: cpa-gui/gpt-6-sol:high
  advisor: cpa-gui/gpt-6-astra:high
'@ | Set-Content -LiteralPath $configPath -Encoding utf8

Write-Output 'Configured OMP. Verify with: omp models cpa-gui'
