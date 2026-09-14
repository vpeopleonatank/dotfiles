#!/usr/bin/env bash

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TEST_HOME=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")
trap 'rm -rf "$TEST_HOME"' EXIT
MINIMAL_PATH=/usr/bin:/bin:/usr/sbin:/sbin
export XDG_CONFIG_HOME="$TEST_HOME/.config"
source "$ROOT/scripts/dotfiles-lib.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file_contains() {
  grep -Fq "$2" "$1" || fail "$1 does not contain $2"
}

assert_link_target() {
  [ -L "$1" ] || fail "expected symlink: $1"
  [ "$(readlink "$1")" = "$2" ] || fail "unexpected symlink target: $1"
}

SOURCE_ROOT="$TEST_HOME/source-root"
mkdir -p "$SOURCE_ROOT"
printf '%s\n' 'outside source' > "$TEST_HOME/outside-source"
ln -s "$TEST_HOME/outside-source" "$SOURCE_ROOT/source"
if DOTFILES_ROOT="$SOURCE_ROOT" dotfiles_link "$SOURCE_ROOT/source" "$TEST_HOME/source-target"; then
  fail 'repository source symlink escaped the repository'
fi

bash -n "$ROOT/setup_zsh.sh" "$ROOT/config.sh" "$ROOT/install.sh" "$ROOT/scripts/dotfiles-lib.sh"
zsh -n "$ROOT/zsh/config.zsh" "$ROOT/zsh/zenvs.zsh" "$ROOT/zsh/zaliases.zsh" "$ROOT/zsh/zfunctions.zsh"

printf '%s\n' '# user-owned content' 'export KEEP_ME=1' > "$TEST_HOME/.zshrc"
HOME="$TEST_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/setup_zsh.sh"
cp "$TEST_HOME/.zshrc" "$TEST_HOME/.zshrc.first"
HOME="$TEST_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/setup_zsh.sh"
cmp -s "$TEST_HOME/.zshrc.first" "$TEST_HOME/.zshrc" || fail 'second setup changed .zshrc'
assert_file_contains "$TEST_HOME/.zshrc" 'export KEEP_ME=1'
assert_file_contains "$TEST_HOME/.zshrc" '$DOTFILES_ROOT/zsh/config.zsh'
assert_link_target "$TEST_HOME/.config/dotfiles" "$ROOT"
[ "$(grep -Fc '# >>> dotfiles managed zsh >>>' "$TEST_HOME/.zshrc")" -eq 1 ] || fail 'duplicate managed blocks'

LINK_HOME="$TEST_HOME/relocated-home"
mkdir -p "$LINK_HOME"
ln -s "$ROOT/setup_zsh.sh" "$LINK_HOME/setup-zsh"
HOME="$LINK_HOME" XDG_CONFIG_HOME="$LINK_HOME/.config" PATH="$MINIMAL_PATH" bash "$LINK_HOME/setup-zsh"
assert_file_contains "$LINK_HOME/.zshrc" '$DOTFILES_ROOT/zsh/config.zsh'
assert_link_target "$LINK_HOME/.config/dotfiles" "$ROOT"

SYMLINK_HOME="$TEST_HOME/symlink-home"
mkdir -p "$SYMLINK_HOME"
printf '%s\n' 'external zshrc' > "$TEST_HOME/external-zshrc"
ln -s "$TEST_HOME/external-zshrc" "$SYMLINK_HOME/.zshrc"
if HOME="$SYMLINK_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/setup_zsh.sh"; then
  fail 'symlinked .zshrc conflict did not report failure'
fi
assert_link_target "$SYMLINK_HOME/.zshrc" "$TEST_HOME/external-zshrc"

MALFORMED_HOME="$TEST_HOME/malformed-home"
mkdir -p "$MALFORMED_HOME"
printf '%s\n' '# >>> dotfiles managed zsh >>>' '# >>> dotfiles managed zsh >>>' '# <<< dotfiles managed zsh <<<' > "$MALFORMED_HOME/.zshrc"
if HOME="$MALFORMED_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/setup_zsh.sh"; then
  fail 'nested managed markers did not report failure'
fi

DRY_FONT_HOME="$TEST_HOME/dry-font-home"
mkdir -p "$DRY_FONT_HOME"
STUB_BIN="$TEST_HOME/stub-bin"
mkdir -p "$STUB_BIN"
cat > "$STUB_BIN/uname" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
  -s) printf 'Darwin\n' ;;
  -m) printf 'arm64\n' ;;
  *) printf 'Darwin\n' ;;
esac
EOF
cat > "$STUB_BIN/brew" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$BREW_LOG"
EOF
chmod +x "$STUB_BIN/uname" "$STUB_BIN/brew"
if ! BREW_LOG="$TEST_HOME/brew.log" HOME="$DRY_FONT_HOME" PATH="$STUB_BIN:$MINIMAL_PATH" \
  bash "$ROOT/setup_zsh.sh" --install-fonts --dry-run; then
  fail 'font dry-run failed'
fi
[ ! -d "$DRY_FONT_HOME/Library/Fonts" ] || fail 'font dry-run created a directory'

OPTIONAL_HOME="$TEST_HOME/optional-home"
mkdir -p "$OPTIONAL_HOME"
printf '%s\n' 'foreign p10k' > "$TEST_HOME/foreign-p10k"
ln -s "$TEST_HOME/foreign-p10k" "$OPTIONAL_HOME/powerlevel10k"
if HOME="$OPTIONAL_HOME" XDG_CONFIG_HOME="$OPTIONAL_HOME/.config" PATH="$MINIMAL_PATH" \
  bash "$ROOT/setup_zsh.sh" --install-p10k; then
  fail 'foreign Powerlevel10k symlink did not report failure'
fi
assert_link_target "$OPTIONAL_HOME/powerlevel10k" "$TEST_HOME/foreign-p10k"

CONFIG_HOME="$TEST_HOME/config-home"
mkdir -p "$CONFIG_HOME/.config/nvim"
printf '%s\n' 'external nvim config' > "$CONFIG_HOME/.config/nvim/marker"
HOME="$CONFIG_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/config.sh"
assert_link_target "$CONFIG_HOME/.config/kitty/kitty.conf" "$ROOT/kitty/kitty.conf"
assert_link_target "$CONFIG_HOME/.tmux.conf" "$ROOT/tmux/config.tmux"
[ -f "$CONFIG_HOME/.config/nvim/marker" ] || fail 'external nvim config changed'

CONFLICT_HOME="$TEST_HOME/conflict-home"
mkdir -p "$CONFLICT_HOME"
printf '%s\n' 'keep this tmux config' > "$CONFLICT_HOME/.tmux.conf"
if HOME="$CONFLICT_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/config.sh"; then
  fail 'regular-file conflict did not report failure'
fi
assert_file_contains "$CONFLICT_HOME/.tmux.conf" 'keep this tmux config'

FOREIGN_HOME="$TEST_HOME/foreign-home"
mkdir -p "$FOREIGN_HOME/.config/kitty"
printf '%s\n' 'foreign' > "$FOREIGN_HOME/foreign-kitty.conf"
ln -s "$FOREIGN_HOME/foreign-kitty.conf" "$FOREIGN_HOME/.config/kitty/kitty.conf"
if HOME="$FOREIGN_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/config.sh"; then
  fail 'foreign-link conflict did not report failure'
fi
assert_link_target "$FOREIGN_HOME/.config/kitty/kitty.conf" "$FOREIGN_HOME/foreign-kitty.conf"

HISTORY_HOME="$TEST_HOME/history-home"
mkdir -p "$HISTORY_HOME"
HOME="$HISTORY_HOME" PATH="$MINIMAL_PATH" zsh -f -i -c \
  "source '$ROOT/zsh/config.zsh'; [[ \"\$HISTFILE\" == \"$HISTORY_HOME/.zsh_history\" ]] && [[ \"\$SAVEHIST\" -eq 100000 ]]"

EMPTY_BIN="$TEST_HOME/empty-zhist-bin"
mkdir -p "$EMPTY_BIN"
printf '%s\n' '#!/bin/sh' 'exit 0' > "$EMPTY_BIN/zhist"
printf '%s\n' '#!/bin/sh' 'printf "0.60.0\\n"' > "$EMPTY_BIN/fzf"
chmod +x "$EMPTY_BIN/zhist" "$EMPTY_BIN/fzf"
EMPTY_HOME="$TEST_HOME/empty-zhist-home"
mkdir -p "$EMPTY_HOME"
HOME="$EMPTY_HOME" XDG_CONFIG_HOME="$EMPTY_HOME/.config" PATH="$EMPTY_BIN:$MINIMAL_PATH" zsh -f -i -c \
  "source '$ROOT/zsh/config.zsh'; [[ \"\$DOTFILES_ZHIST_INITIALIZED\" -eq 0 && \"\$HISTFILE\" == \"\$HOME/.zsh_history\" && \"\$SAVEHIST\" -eq 100000 && \"\$ZSH_AUTOSUGGEST_STRATEGY\" == history ]]"

MATRIX_LOG="$TEST_HOME/matrix.log"
BREW_LOG="$TEST_HOME/brew.log" HOME="$TEST_HOME" PATH="$STUB_BIN:$MINIMAL_PATH" \
  bash "$ROOT/setup_zsh.sh" --install-packages --dry-run > "$MATRIX_LOG"
BREW_LOG="$TEST_HOME/brew.log" HOME="$TEST_HOME" PATH="$STUB_BIN:$MINIMAL_PATH" \
  bash "$ROOT/install.sh" --install-zhist --dry-run >> "$MATRIX_LOG"
assert_file_contains "$MATRIX_LOG" 'brew install zsh git'
assert_file_contains "$MATRIX_LOG" 'brew install fzf'
assert_file_contains "$MATRIX_LOG" 'brew tap overflowy/tap'

LINUX_BIN="$TEST_HOME/linux-bin"
mkdir -p "$LINUX_BIN"
cat > "$LINUX_BIN/uname" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
  -s) printf 'Linux\n' ;;
  -m) printf 'x86_64\n' ;;
  *) printf 'Linux\n' ;;
esac
EOF
cat > "$LINUX_BIN/apt-get" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$LINUX_BIN/sudo" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$LINUX_BIN/uname" "$LINUX_BIN/apt-get" "$LINUX_BIN/sudo"
printf '%s\n' 'ID=linuxmint' 'ID_LIKE=debian' > "$TEST_HOME/linuxmint-release"
if DOTFILES_OS_RELEASE_FILE="$TEST_HOME/linuxmint-release" HOME="$TEST_HOME" PATH="$LINUX_BIN:$MINIMAL_PATH" \
  bash "$ROOT/install.sh" --install-core --dry-run; then
  fail 'unsupported Linux derivative was accepted'
fi
printf '%s\n' 'ID=ubuntu' 'ID_LIKE=debian' > "$TEST_HOME/ubuntu-release"
LINUX_LOG="$TEST_HOME/linux.log"
DOTFILES_OS_RELEASE_FILE="$TEST_HOME/ubuntu-release" HOME="$TEST_HOME" PATH="$LINUX_BIN:$MINIMAL_PATH" \
  bash "$ROOT/install.sh" --install-core --dry-run > "$LINUX_LOG"
assert_file_contains "$LINUX_LOG" 'sudo apt-get update'
assert_file_contains "$LINUX_LOG" 'sudo apt-get install'

MARKER_HOME="$TEST_HOME/marker-home"
mkdir -p "$MARKER_HOME"
printf '%s\n' 'outside marker' > "$TEST_HOME/outside-marker"
ln -s "$TEST_HOME/outside-marker" "$MARKER_HOME/tmux_no_auto_restore"
if HOME="$MARKER_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/config.sh"; then
  fail 'marker symlink conflict did not report failure'
fi
assert_link_target "$MARKER_HOME/tmux_no_auto_restore" "$TEST_HOME/outside-marker"

TPM_HOME="$TEST_HOME/tpm-home"
mkdir -p "$TPM_HOME/.tmux/plugins" "$TEST_HOME/foreign-tpm"
ln -s "$TEST_HOME/foreign-tpm" "$TPM_HOME/.tmux/plugins/tpm"
if HOME="$TPM_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/config.sh" --install-tpm; then
  fail 'foreign TPM symlink did not report failure'
fi
assert_link_target "$TPM_HOME/.tmux/plugins/tpm" "$TEST_HOME/foreign-tpm"

if HOME="$TEST_HOME" PATH="$MINIMAL_PATH" bash "$ROOT/install.sh" --install-zhist --dry-run; then
  fail 'unsupported package-manager path unexpectedly succeeded'
fi

printf 'PASS: dotfiles fixture tests\n'
