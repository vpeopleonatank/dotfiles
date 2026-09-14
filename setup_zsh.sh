#!/usr/bin/env bash

set -u

resolve_entrypoint() {
  local path="$1" directory target
  while [ -L "$path" ]; do
    directory=$(cd -P "$(dirname "$path")" && pwd) || return 1
    target=$(readlink "$path") || return 1
    case "$target" in
      /*) path="$target" ;;
      *) path="$directory/$target" ;;
    esac
  done
  directory=$(cd -P "$(dirname "$path")" && pwd) || return 1
  printf '%s/%s\n' "$directory" "$(basename "$path")"
}

SCRIPT_PATH=$(resolve_entrypoint "${BASH_SOURCE[0]}") || exit 1
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
. "$SCRIPT_DIR/scripts/dotfiles-lib.sh"
DOTFILES_ROOT=$(dotfiles_repo_root_from_script "$SCRIPT_PATH") || exit 1
export DOTFILES_ROOT

install_packages=0 set_default_shell=0 install_fonts_flag=0 install_p10k=0 install_plugins=0

usage() {
  cat <<'EOF'
Usage: setup_zsh.sh [options]

Updates ~/.zshrc by default without replacing existing content.

  --install-packages   Install zsh and git with Homebrew or APT.
  --set-default-shell  Explicitly request chsh after zsh is available.
  --install-fonts      Download JetBrains Mono Nerd Font files for this user.
  --install-p10k       Clone Powerlevel10k into ~/powerlevel10k if absent.
  --install-plugins    Clone zsh-snap into ~/.zsh/zsh-snap if absent.
  --all                Enable all optional actions above.
  --dry-run            Report writes and commands without changing the host.
  -h, --help           Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --install-packages) install_packages=1 ;;
    --set-default-shell) set_default_shell=1 ;;
    --install-fonts) install_fonts_flag=1 ;;
    --install-p10k) install_p10k=1 ;;
    --install-plugins) install_plugins=1 ;;
    --all) install_packages=1; set_default_shell=1; install_fonts_flag=1; install_p10k=1; install_plugins=1 ;;
    --dry-run) DOTFILES_DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

update_zshrc() {
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc" source_link block
  source_link="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
  dotfiles_link "$DOTFILES_ROOT" "$source_link" || return
  block=$(cat <<'EOF'
if [ -z "${DOTFILES_ROOT:-}" ]; then
  DOTFILES_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
fi
if [ -r "$DOTFILES_ROOT/zsh/config.zsh" ]; then
  source "$DOTFILES_ROOT/zsh/config.zsh"
fi
EOF
)
  dotfiles_update_managed_block "$zshrc" \
    '# >>> dotfiles managed zsh >>>' \
    '# <<< dotfiles managed zsh <<<' "$block"
}

install_packages() {
  if ! dotfiles_detect_platform; then dotfiles_print_platform_guidance; return 1; fi
  dotfiles_platform_summary
  case "$DOTFILES_PACKAGE_MANAGER" in
    brew) dotfiles_run brew install zsh git ;;
    apt)
      if [ "${DOTFILES_DRY_RUN:-0}" -ne 1 ]; then dotfiles_require_command sudo || return 1; fi
      dotfiles_run sudo apt-get update || return 1
      dotfiles_run sudo apt-get install -y zsh git
      ;;
  esac
}

install_p10k() {
  local target="$HOME/powerlevel10k"
  if [ -L "$target" ]; then
    printf 'Conflict: Powerlevel10k symlink retained: %s\n' "$target" >&2
    return 2
  elif [ -d "$target" ]; then
    printf 'Powerlevel10k already exists: %s\n' "$target"
  elif [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    printf 'Would clone Powerlevel10k into %s\n' "$target"
  else
    dotfiles_require_command git || return 1
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
  fi
}

install_plugins() {
  local target="$HOME/.zsh/zsh-snap"
  if [ -L "$target" ]; then
    printf 'Conflict: zsh-snap symlink retained: %s\n' "$target" >&2
    return 2
  elif [ -d "$target" ]; then
    printf 'zsh-snap already exists: %s\n' "$target"
  elif [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    printf 'Would clone zsh-snap into %s\n' "$target"
  else
    dotfiles_require_command git || return 1
    mkdir -p "$(dirname "$target")" || return 1
    git clone --depth=1 https://github.com/marlonrichert/zsh-snap.git "$target"
  fi
}

install_fonts() {
  local fonts_dir file_name file_path file_url type
  local -a downloader
  if [ "${DOTFILES_OS:-}" = macos ]; then fonts_dir="$HOME/Library/Fonts"; else fonts_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"; fi
  if [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    for type in Bold Medium Italic 'Bold Italic'; do
      file_name="JetBrainsMonoNerdFontMono-${type}.ttf"
      printf 'Would download %s/%s\n' "$fonts_dir" "$file_name"
    done
    return 0
  fi
  mkdir -p "$fonts_dir" || return 1
  if command -v curl >/dev/null 2>&1; then downloader=(curl -fsSL -o); elif command -v wget >/dev/null 2>&1; then downloader=(wget -qO); else printf 'Install fonts skipped: curl or wget is required.\n' >&2; return 1; fi
  for type in Bold Medium Italic 'Bold Italic'; do
    file_name="JetBrainsMonoNerdFontMono-${type}.ttf"
    file_path="$fonts_dir/$file_name"
    file_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/${type}/${file_name}"
    if [ -L "$file_path" ]; then printf 'Conflict: font symlink retained: %s\n' "$file_path" >&2; return 2; elif [ -e "$file_path" ]; then printf 'Font already exists: %s\n' "$file_path"; else "${downloader[@]}" "$file_path" "$file_url" || return 1; fi
  done
  if command -v fc-cache >/dev/null 2>&1; then dotfiles_run fc-cache -f "$fonts_dir"; fi
}

failures=0
update_zshrc || failures=$((failures + 1))
if [ "$install_packages" -eq 1 ]; then install_packages || failures=$((failures + 1)); fi
if [ "$install_p10k" -eq 1 ]; then install_p10k || failures=$((failures + 1)); fi
if [ "$install_plugins" -eq 1 ]; then install_plugins || failures=$((failures + 1)); fi
if [ "$install_fonts_flag" -eq 1 ]; then
  if dotfiles_detect_platform; then install_fonts || failures=$((failures + 1)); else dotfiles_print_platform_guidance; failures=$((failures + 1)); fi
fi
if [ "$set_default_shell" -eq 1 ]; then
  zsh_path=$(command -v zsh || true)
  if [ -z "$zsh_path" ]; then
    printf 'Default shell unchanged: zsh is not available.\n' >&2; failures=$((failures + 1))
  elif [ ! -t 0 ] || [ ! -t 1 ]; then
    printf 'Default shell unchanged: --set-default-shell requires an interactive terminal; run chsh -s %s manually.\n' "$zsh_path" >&2; failures=$((failures + 1))
  elif [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    printf 'Would run chsh -s %s\n' "$zsh_path"
  else
    chsh -s "$zsh_path" || failures=$((failures + 1))
  fi
fi
exit "$failures"
