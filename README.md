# dotfiles

Portable shell, terminal, tmux, snippets, and utility configuration.

## Supported setup

Automated provisioning is limited to:

- macOS with Homebrew, on amd64 or arm64;
- Debian or Ubuntu Linux with APT, on amd64 or arm64.

Other systems receive diagnostics and no guessed package or network command.
The scripts never require root for files below `$HOME`.

## Install

Clone the repository anywhere, then update the shell startup file:

```bash
git clone https://github.com/vpeopleonatank/dotfiles.git "$HOME/.config/dotfiles-repo"
cd "$HOME/.config/dotfiles-repo"
bash setup_zsh.sh
```

Run the remaining commands from the clone directory, or replace each script
name with its path.

`setup_zsh.sh` preserves all existing `.zshrc` content and maintains one marked
source block. It performs no package installation, shell change, font download,
or network clone unless explicitly requested:

```bash
bash setup_zsh.sh --install-packages
bash setup_zsh.sh --install-plugins --install-p10k --install-fonts
bash setup_zsh.sh --set-default-shell
```

Use `--dry-run` to inspect actions first. `chsh` requires an interactive
terminal and is never mandatory.

Setup also creates the conflict-safe `~/.config/dotfiles` symlink used by the
managed source block, so the startup file does not embed the clone path.

Install optional dependencies separately:

```bash
bash install.sh --install-core
bash install.sh --install-tools
bash install.sh --install-zhist
```

The Linux zhist path downloads and verifies the pinned `v1.2.1` amd64 or arm64
release asset. zhist remains optional; without it, native persistent Zsh
history uses `~/.zsh_history`.

Apply non-editor links with:

```bash
bash config.sh
```

Existing files, directories, and foreign symlinks are retained and reported.
TPM is an explicit network action:

```bash
bash config.sh --install-tpm
```

Vim and Neovim configuration are not owned by this repository. The tracked
`vim/` and `nvim/` trees are removed, and `config.sh` does not alter an existing
`~/.config/nvim` target or install editor plugins.

## zhist migration

When `zhist` and compatible `fzf` are installed, startup initializes zhist late
with `zhist init -no-arrow-binds`. This keeps native and vi-mode arrow behavior;
`Ctrl-R` is owned by zhist and opens with the current command-line text as its
initial search. `Ctrl-X` retains the configured `run-again` meaning in Zsh maps,
while the zhist picker has its own `Ctrl-X` action.

Import legacy history once, only when the source exists and the zhist store is
absent or empty:

```bash
zhist_store="${ZHIST_FILE:-${XDG_DATA_HOME:-$HOME/.local/share}/zhist/history.jsonl}"
if [[ -r "$HOME/.zsh_history" && ! -s "$zhist_store" ]]; then
  zhist import "$HOME/.zsh_history"
fi
```

Startup never imports or deletes history. Imported records do not contain the
legacy directory, status, or duration metadata. Keep the legacy file until the
new store has been checked.

## Host-local configuration and rollback

Machine-specific exports, aliases, and any personal Cheat path belong in the
ignored `zsh/local.zsh` file. `DOTFILES_LOCAL_CONFIG` can point to another
local file.
When migrating an older checkout, copy the host-specific settings you still
need into that file instead of committing them. Committed startup checks
optional tool paths defensively; unavailable paths are skipped without startup
errors.

To roll back shell startup, remove only the block between
`# >>> dotfiles managed zsh >>>` and `# <<< dotfiles managed zsh <<<` in
`~/.zshrc`; all other lines remain unchanged. Remove links only when their
target points to this clone. Remove `~/tmux_no_auto_restore` only if this setup
created it and it did not exist beforehand. To restore native history while
keeping this source block, start a shell where `zhist` and `fzf` are unavailable;
the fallback uses `~/.zsh_history`. The legacy history file remains untouched.
