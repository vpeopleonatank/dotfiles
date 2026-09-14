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

install_core=0 install_tools=0 install_zhist=0
usage() {
  cat <<'EOF'
Usage: install.sh [options]

No package or network action runs without an explicit option.

  --install-core       Install zsh, git, tmux, curl, and wget.
  --install-tools      Install optional fzf, ripgrep, bat, and fd packages.
  --install-zhist      Install zhist and verify compatible fzf.
  --all                Enable all supported package groups.
  --dry-run            Report commands without changing the host.
  -h, --help           Show this help.
EOF
}
while [ "$#" -gt 0 ]; do
  case "$1" in
    --install-core) install_core=1 ;;
    --install-tools) install_tools=1 ;;
    --install-zhist) install_zhist=1 ;;
    --all) install_core=1; install_tools=1; install_zhist=1 ;;
    --dry-run) DOTFILES_DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
if [ "$install_core" -eq 0 ] && [ "$install_tools" -eq 0 ] && [ "$install_zhist" -eq 0 ]; then usage; exit 0; fi
if ! dotfiles_detect_platform; then dotfiles_print_platform_guidance; exit 1; fi
dotfiles_platform_summary

package_install() {
  local package_list="$1"
  local -a package_array
  read -r -a package_array <<< "$package_list"
  if [ "$DOTFILES_PACKAGE_MANAGER" = brew ]; then
    dotfiles_run brew install "${package_array[@]}"
  else
    if [ "${DOTFILES_DRY_RUN:-0}" -ne 1 ]; then dotfiles_require_command sudo || return 1; fi
    dotfiles_run sudo apt-get update || return 1
    dotfiles_run sudo apt-get install -y "${package_array[@]}"
  fi
}
if [ "$install_core" -eq 1 ]; then package_install 'zsh git tmux curl wget' || exit 1; fi
if [ "$install_tools" -eq 1 ]; then
  if [ "$DOTFILES_PACKAGE_MANAGER" = brew ]; then package_install 'fzf ripgrep bat fd'; else package_install 'fzf ripgrep bat fd-find'; fi
  [ "$?" -eq 0 ] || exit 1
fi

fzf_version_ok() {
  local version major minor
  version=$(fzf --version 2>/dev/null | awk 'NR == 1 {print $1}')
  major=${version%%.*}; minor=${version#*.}; minor=${minor%%.*}
  if [ "${major:-0}" -gt 0 ]; then return 0; fi
  [ "${minor:-0}" -ge 45 ]
}
verify_zhist_dependencies() {
  export PATH="$HOME/.local/bin:$PATH"
  command -v zhist >/dev/null 2>&1 || { printf 'zhist is not available on PATH after provisioning.\n' >&2; return 1; }
  command -v fzf >/dev/null 2>&1 || { printf 'fzf >= 0.45 is required for zhist.\n' >&2; return 1; }
  fzf_version_ok || { printf 'fzf is too old for zhist; upgrade to >= 0.45.\n' >&2; return 1; }
  printf 'Verified zhist and compatible fzf.\n'
}
install_zhist_macos() {
  if [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then printf 'Would run brew tap overflowy/tap and brew install overflowy/tap/zhist\n'; return 0; fi
  dotfiles_run brew tap overflowy/tap || return 1
  dotfiles_run brew install overflowy/tap/zhist
}
install_zhist_linux() {
  local asset="zhist_1.2.1_linux_${DOTFILES_ARCH}.tar.gz" base_url="https://github.com/overflowy/zhist/releases/download/v1.2.1"
  local target="$HOME/.local/bin/zhist" temp expected actual archive
  [ "$DOTFILES_ARCH" = amd64 ] || [ "$DOTFILES_ARCH" = arm64 ] || { printf 'No Linux zhist asset is published for architecture: %s\n' "$DOTFILES_ARCH" >&2; return 1; }
  if [ -L "$target" ]; then printf 'Conflict: zhist symlink retained: %s\n' "$target" >&2; return 2; fi
  if [ -x "$target" ]; then printf 'zhist already exists: %s\n' "$target"; return 0; fi
  if [ -e "$target" ]; then printf 'Conflict: non-executable zhist target retained: %s\n' "$target" >&2; return 1; fi
  if [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then printf 'Would download and verify pinned asset %s into %s\n' "$asset" "$target"; return 0; fi
  dotfiles_require_command tar || return 1
  if command -v curl >/dev/null 2>&1; then download() { curl -fsSL -o "$1" "$2"; }; elif command -v wget >/dev/null 2>&1; then download() { wget -qO "$1" "$2"; }; else printf 'A network downloader is required for the pinned Linux zhist asset.\n' >&2; return 1; fi
  temp=$(mktemp -d) || return 1
  trap 'rm -rf "$temp"' RETURN
  archive="$temp/$asset"
  download "$archive" "$base_url/$asset" || return 1
  download "$temp/checksums.txt" "$base_url/checksums.txt" || return 1
  expected=$(awk -v name="$asset" '$2 == name {print $1}' "$temp/checksums.txt")
  [ -n "$expected" ] || { printf 'No checksum was published for %s.\n' "$asset" >&2; return 1; }
  if command -v sha256sum >/dev/null 2>&1; then actual=$(sha256sum "$archive" | awk '{print $1}'); else actual=$(shasum -a 256 "$archive" | awk '{print $1}'); fi
  [ "$actual" = "$expected" ] || { printf 'Checksum mismatch for %s.\n' "$asset" >&2; return 1; }
  mkdir -p "$HOME/.local/bin" || return 1
  tar -xzf "$archive" -C "$temp" || return 1
  [ -f "$temp/zhist" ] || { printf 'Pinned archive did not contain the expected zhist executable.\n' >&2; return 1; }
  install -m 0755 "$temp/zhist" "$target"
}
if [ "$install_zhist" -eq 1 ]; then
  if ! command -v fzf >/dev/null 2>&1; then package_install fzf || exit 1; fi
  if [ "$DOTFILES_OS" = macos ]; then install_zhist_macos || exit 1; else install_zhist_linux || exit 1; fi
  if [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    printf 'Would verify zhist and compatible fzf after installation.\n'
  else
    verify_zhist_dependencies || exit 1
  fi
fi
