#!/usr/bin/env bash

if [ "${DOTFILES_LIB_LOADED:-0}" -eq 1 ]; then
  return 0
fi
DOTFILES_LIB_LOADED=1

dotfiles_resolve_path() {
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

dotfiles_repo_root_from_script() {
  local script_path
  script_path=$(dotfiles_resolve_path "$1") || return 1
  cd -P "$(dirname "$script_path")" && pwd
}

dotfiles_detect_platform() {
  DOTFILES_OS=unsupported
  DOTFILES_ARCH=unknown
  DOTFILES_PACKAGE_MANAGER=none
  DOTFILES_PLATFORM_REASON=""
  case "$(uname -s 2>/dev/null || true)" in
    Darwin) DOTFILES_OS=macos ;;
    Linux) DOTFILES_OS=linux ;;
    *) DOTFILES_PLATFORM_REASON="supported systems are macOS and Debian/Ubuntu Linux" ;;
  esac
  case "$(uname -m 2>/dev/null || true)" in
    x86_64|amd64) DOTFILES_ARCH=amd64 ;;
    arm64|aarch64) DOTFILES_ARCH=arm64 ;;
    *) DOTFILES_ARCH=unknown ;;
  esac
  if [ "$DOTFILES_OS" = linux ]; then
    local release_file="${DOTFILES_OS_RELEASE_FILE:-/etc/os-release}"
    if [ ! -r "$release_file" ]; then
      DOTFILES_OS=unsupported
      DOTFILES_PLATFORM_REASON="Linux distribution metadata is unavailable"
    else
      . "$release_file"
      case "${ID:-}" in
        ubuntu|debian) ;;
        *)
          DOTFILES_OS=unsupported
          DOTFILES_PLATFORM_REASON="only Debian and Ubuntu Linux are supported"
          ;;
      esac
    fi
  fi
  if [ "$DOTFILES_OS" = macos ] && command -v brew >/dev/null 2>&1; then
    DOTFILES_PACKAGE_MANAGER=brew
  elif [ "$DOTFILES_OS" = linux ] && command -v apt-get >/dev/null 2>&1; then
    DOTFILES_PACKAGE_MANAGER=apt
  fi
  if [ "$DOTFILES_OS" = unsupported ]; then return 1; fi
  if [ "$DOTFILES_ARCH" = unknown ]; then
    DOTFILES_PLATFORM_REASON="architecture must be amd64 or arm64"
    return 1
  fi
  if [ "$DOTFILES_PACKAGE_MANAGER" = none ]; then
    DOTFILES_PLATFORM_REASON="the supported package manager is unavailable"
    return 1
  fi
}

dotfiles_platform_summary() {
  printf 'Platform: os=%s arch=%s package-manager=%s\n' \
    "${DOTFILES_OS:-unknown}" "${DOTFILES_ARCH:-unknown}" "${DOTFILES_PACKAGE_MANAGER:-none}"
}

dotfiles_print_platform_guidance() {
  printf 'No changes made: %s.\n' \
    "${DOTFILES_PLATFORM_REASON:-this host is outside the supported platform matrix}" >&2
  printf 'Supported matrix: macOS with Homebrew, or Debian/Ubuntu Linux with APT; amd64 and arm64.\n' >&2
}

dotfiles_run() {
  if [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

dotfiles_require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Required command is unavailable: %s\n' "$1" >&2
    return 1
  fi
}

dotfiles_update_managed_block() {
  local file="$1" begin_marker="$2" end_marker="$3" block="$4"
  local directory temp file_mode
  directory=$(dirname "$file")
  if [ -L "$file" ]; then
    printf 'Conflict: managed file target is a symlink retained: %s\n' "$file" >&2
    return 2
  fi
  if [ -e "$file" ] && [ ! -f "$file" ]; then
    printf 'Conflict: managed file target is not a regular file: %s\n' "$file" >&2
    return 2
  fi
  if [ ! -d "$directory" ] || [ ! -w "$directory" ]; then
    printf 'Cannot write managed file directory: %s\n' "$directory" >&2
    return 1
  fi
  if [ -e "$file" ] && [ ! -w "$file" ]; then
    printf 'Cannot write managed file: %s\n' "$file" >&2
    return 1
  fi
  if [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    printf 'Would update managed block in %s\n' "$file"
    return 0
  fi
  temp=$(mktemp "$directory/.dotfiles-managed.XXXXXX") || return 1
  if [ -f "$file" ]; then
    if ! awk -v begin="$begin_marker" -v end="$end_marker" '
      $0 == begin {
        if (inside || found) { invalid=1; next }
        inside=1; found=1; next
      }
      $0 == end {
        if (!inside) { invalid=1; next }
        inside=0; next
      }
      !inside { print }
      END { if (inside || invalid) exit 2 }
    ' "$file" > "$temp"; then
      rm -f "$temp"
      printf 'Refusing to update malformed managed block: %s\n' "$file" >&2
      return 2
    fi
    file_mode=$(stat -f '%Lp' "$file" 2>/dev/null || stat -c '%a' "$file" 2>/dev/null || true)
    if [ -n "$file_mode" ]; then chmod "$file_mode" "$temp" || { rm -f "$temp"; return 1; }; fi
  fi
  printf '%s\n%s\n%s\n' "$begin_marker" "$block" "$end_marker" >> "$temp"
  if ! mv "$temp" "$file"; then
    rm -f "$temp"
    return 1
  fi
  printf 'Updated managed block in %s\n' "$file"
}

dotfiles_canonical_path() {
  local path="$1" directory
  directory=$(cd -P "$(dirname "$path")" && pwd) || return 1
  printf '%s/%s\n' "$directory" "$(basename "$path")"
}

dotfiles_link() {
  local source="$1" target="$2" source_path target_path link_target root_path
  if [ ! -e "$source" ] && [ ! -L "$source" ]; then
    printf 'Missing repository source: %s\n' "$source" >&2
    return 1
  fi
  source_path=$(dotfiles_resolve_path "$source") || return 1
  if [ -n "${DOTFILES_ROOT:-}" ]; then
    root_path=$(dotfiles_resolve_path "$DOTFILES_ROOT") || return 1
    case "$source_path" in
      "$root_path"|"$root_path"/*) ;;
      *)
        printf 'Conflict: repository source resolves outside the repository: %s\n' "$source" >&2
        return 2
        ;;
    esac
  fi
  if [ -L "$target" ]; then
    link_target=$(readlink "$target") || return 1
    case "$link_target" in
      /*) target_path=$(dotfiles_canonical_path "$link_target") ;;
      *) target_path=$(dotfiles_canonical_path "$(dirname "$target")/$link_target") ;;
    esac
    if [ "$target_path" = "$source_path" ]; then
      printf 'Already linked: %s\n' "$target"
      return 0
    fi
    printf 'Conflict: foreign symlink retained: %s -> %s\n' "$target" "$link_target" >&2
    return 2
  fi
  if [ -e "$target" ]; then
    printf 'Conflict: existing file or directory retained: %s\n' "$target" >&2
    return 2
  fi
  if [ "${DOTFILES_DRY_RUN:-0}" -eq 1 ]; then
    printf 'Would link %s -> %s\n' "$target" "$source_path"
    return 0
  fi
  mkdir -p "$(dirname "$target")" || return 1
  ln -s "$source_path" "$target" || return 1
  printf 'Linked %s -> %s\n' "$target" "$source_path"
}
