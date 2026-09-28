#!/usr/bin/env bash

set -euo pipefail

base_url=${OMP_CPA_GUI_BASE_URL:-http://127.0.0.1:8317/v1}
api_key_env=${OMP_CPA_GUI_API_KEY_ENV:-OMP_CPA_GUI_API_KEY}
dry_run=0
force=0
skip_install=0

usage() {
  cat <<'EOF'
Usage: setup-omp.sh [options]

Install Oh My Pi and configure its local Codex-compatible CPA GUI provider.

Options:
  --base-url URL     Proxy endpoint (default: $OMP_CPA_GUI_BASE_URL or http://127.0.0.1:8317/v1)
  --api-key-env NAME Environment variable holding the proxy bearer token.
  --skip-install     Configure OMP without running its installer.
  --force            Back up and replace existing OMP model and role configuration.
  --dry-run          Print actions without changing the host.
  -h, --help         Show this help.
EOF
}

run() {
  if [ "$dry_run" -eq 1 ]; then
    printf 'Would run:'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --base-url) base_url=${2:?missing value for --base-url}; shift ;;
    --api-key-env) api_key_env=${2:?missing value for --api-key-env}; shift ;;
    --skip-install) skip_install=1 ;;
    --force) force=1 ;;
    --dry-run) dry_run=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

case "$(uname -s)" in
  Darwin|Linux) ;;
  *) printf 'This script supports macOS and Linux. Run setup-omp.ps1 on Windows.\n' >&2; exit 1 ;;
esac

if [ "$skip_install" -eq 0 ] && ! command -v omp >/dev/null 2>&1; then
  if [ "$dry_run" -eq 1 ]; then
    printf 'Would install OMP from https://omp.sh/install\n'
  else
    curl -fsSL https://omp.sh/install | sh
  fi
fi

agent_dir="${OMP_AGENT_DIR:-$HOME/.omp/agent}"
models_file="$agent_dir/models.yml"
config_file="$agent_dir/config.yml"
timestamp=$(date +%Y%m%d%H%M%S)

for file in "$models_file" "$config_file"; do
  if [ -e "$file" ] && [ "$force" -eq 0 ]; then
    printf 'Conflict: existing OMP configuration retained: %s (rerun with --force to back up and replace it)\n' "$file" >&2
    exit 1
  fi
done

if [ "$dry_run" -eq 1 ]; then
  printf 'Would write %s and %s for %s\n' "$models_file" "$config_file" "$base_url"
  exit 0
fi

mkdir -p "$agent_dir"
for file in "$models_file" "$config_file"; do
  if [ -e "$file" ]; then
    mv "$file" "$file.bak-$timestamp"
    printf 'Backed up %s\n' "$file"
  fi
done

cat > "$models_file" <<EOF
providers:
  cpa-gui:
    baseUrl: $base_url
    api: openai-responses
    apiKey: $api_key_env
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
EOF

cat > "$config_file" <<'EOF'
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
EOF

printf 'Configured OMP. Verify with: omp models cpa-gui\n'
