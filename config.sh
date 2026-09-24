#!/usr/bin/env bash

set -u

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

install_tpm=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --install-tpm) install_tpm=1 ;;
    --dry-run) DOTFILES_DRY_RUN=1 ;;
    -h|--help) printf '%s\n' 'Usage: config.sh [--install-tpm] [--dry-run]' 'Links only non-editor configuration. Existing conflicts are retained.'; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

failures=0
for link_pair in \
  "$DOTFILES_ROOT/kitty/kitty.conf|$HOME/.config/kitty/kitty.conf" \
  "$DOTFILES_ROOT/ghostty/config|$HOME/.config/ghostty/config" \
  "$DOTFILES_ROOT/tmux/config.tmux|$HOME/.tmux.conf" \
  "$DOTFILES_ROOT/lazygit/config.yml|$HOME/.config/jesseduffield/lazygit/config.yml" \
  "$DOTFILES_ROOT/snippets|$HOME/.config/snippets"; do
  source_path=${link_pair%%|*}
  target_path=${link_pair#*|}
  dotfiles_link "$source_path" "$target_path" || failures=$((failures + 1))
done

if [ -L "$HOME/tmux_no_auto_restore" ]; then
  printf 'Conflict: tmux marker symlink retained: %s\n' "$HOME/tmux_no_auto_restore" >&2
  failures=$((failures + 1))
elif [ -e "$HOME/tmux_no_auto_restore" ]; then
  printf 'Already present: %s\n' "$HOME/tmux_no_auto_restore"
elif [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
  printf 'Would create %s\n' "$HOME/tmux_no_auto_restore"
else
  : > "$HOME/tmux_no_auto_restore" || failures=$((failures + 1))
fi

if [ "$install_tpm" -eq 1 ]; then
  tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ -L "$tpm_dir" ]; then printf 'Conflict: TPM symlink retained: %s\n' "$tpm_dir" >&2; failures=$((failures + 1));
  elif [ -d "$tpm_dir" ]; then printf 'TPM already exists: %s\n' "$tpm_dir";
  elif [ -e "$tpm_dir" ]; then printf 'Conflict: TPM target retained: %s\n' "$tpm_dir" >&2; failures=$((failures + 1));
  elif [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then printf 'Would clone TPM into %s\n' "$tpm_dir";
  elif dotfiles_require_command git; then mkdir -p "$(dirname "$tpm_dir")" && git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || failures=$((failures + 1));
  else failures=$((failures + 1)); fi
fi

printf 'Vim and Neovim configuration is external; no editor paths were changed.\n'
exit "$failures"
