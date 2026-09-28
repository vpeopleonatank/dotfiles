#!/usr/bin/env bash

set -euo pipefail

resolve_entrypoint() {
  local path="$1" directory target
  while [ -L "$path" ]; do
    directory=$(cd -P "$(dirname "$path")" && pwd) || return 1
    target=$(readlink "$path") || return 1
    case "$target" in /*) path="$target" ;; *) path="$directory/$target" ;; esac
  done
  directory=$(cd -P "$(dirname "$path")" && pwd) || return 1
  printf '%s/%s\n' "$directory" "$(basename "$path")"
}

SCRIPT_PATH=$(resolve_entrypoint "${BASH_SOURCE[0]}") || exit 1
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
. "$SCRIPT_DIR/scripts/dotfiles-lib.sh"
DOTFILES_ROOT=$(dotfiles_repo_root_from_script "$SCRIPT_PATH") || exit 1
export DOTFILES_ROOT

dry_run=0
case "${1:-}" in
  '') ;;
  --dry-run) dry_run=1 ;;
  -h|--help) printf '%s\n' 'Usage: setup-omp.sh [--dry-run]' 'Links tracked OMP configuration files. Existing files are retained.'; exit 0 ;;
  *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
esac

agent_dir="${OMP_AGENT_DIR:-$HOME/.omp/agent}"
if [ "$dry_run" -eq 1 ]; then DOTFILES_DRY_RUN=1; fi

failures=0
for file in models.yml config.yml; do
  dotfiles_link "$DOTFILES_ROOT/omp/agent/$file" "$agent_dir/$file" || failures=$((failures + 1))
done

exit "$failures"
