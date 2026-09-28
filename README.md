# dotfiles

Portable shell, terminal, tmux/psmux, snippets, and utility configuration.

## Supported setup

Automated provisioning is limited to:

- macOS with Homebrew, on amd64 or arm64;
- Debian or Ubuntu Linux with APT, on amd64 or arm64.

Windows is supported for PowerShell aliases, Neovim, psmux, and Herdr configuration.
Shell, tmux, and package provisioning remain limited to macOS and Debian/Ubuntu.
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

`--install-tools` also installs `markdownlint-cli` globally with npm. If npm
is not already available from an active Node/NVM installation, the script
installs Node.js and npm through the supported system package manager first.

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

On Windows, psmux reads the tracked `psmux/config.psmux` file through the
`~/.psmux.conf` symlink when `psmux` is on `PATH`. It keeps the shared key
bindings and Tokyo Night styling while using the maintained public Windows
ports for TPM, resurrect, continuum, prefix highlight, and vim navigation:

```powershell
.\setup-psmux.ps1 -InstallPlugins
```

That option installs only PPM (the psmux plugin manager); start psmux and press
`Prefix + I` to fetch the declared plugins. psmux's native clipboard support
replaces tmux-yank, and plugins without maintained psmux ports are not loaded.
PowerShell predictions stay enabled without psmux's extra prediction dimming.
Use `Alt` + `1` through `9` to select the corresponding psmux window.

Herdr uses the same portable tmux-style bindings on Windows, macOS, and Linux:
`Ctrl-Q` is the prefix; `Prefix` + `-` or `_` splits panes; `Prefix` +
`H/J/K/L` focuses panes; `Prefix` + `Shift-H/J/K/L` resizes panes; `Prefix` +
`Ctrl-H/Ctrl-L` changes tabs; and
`Prefix` + `1` through `9` selects a tab. On macOS or Linux, `config.sh`
links the configuration to `~/.config/herdr/config.toml`:

```bash
bash config.sh
```

On Windows, link it to `%APPDATA%\herdr\config.toml`:

```powershell
.\setup-herdr.ps1
```

Install Herdr separately, then reload a running server after changes with
`herdr server reload-config`.

Install the portable PowerShell shortcuts into the current host's user profile:

```powershell
.\setup-powershell.ps1
```

They provide `g`, `lg`, `t`, `v`, `nv`, `jl`, and `lzd`, plus `vimdiff`, `ez`,
`lsh`, `dcl`, `downsub`, and `downplaylistbest`, matching the corresponding
Linux/macOS command shortcuts where the tools are installed. Reopen PowerShell
after setup, or run `lsh` in the current session.

Set up Neovim on Windows (PowerShell; Neovim must already be installed):

```powershell
.\setup-nvim.ps1
```

The script links the tracked `nvim/` tree to `%LOCALAPPDATA%\nvim`, preserves
an existing config as a conflict, and supports `-DryRun`.

## Oh My Pi with the local Codex proxy

The setup scripts install [Oh My Pi](https://omp.sh/) when needed and configure
its `cpa-gui` provider to match the local Codex proxy. They configure Terra as
the default model, Luna for lightweight work, GPT-6 Sol for thorough, planning,
vision, and task work, and Astra for Advisor.

On macOS or Linux:

```bash
bash setup-omp.sh
```

On Windows:

```powershell
.\setup-omp.ps1
```

Both scripts use `http://127.0.0.1:8317/v1` and the local proxy's default
token. Set `OMP_CPA_GUI_BASE_URL` and `OMP_CPA_GUI_API_KEY`, or pass
`--base-url` / `--api-key` on macOS/Linux and `-BaseUrl` / `-ApiKey` on
Windows, to use another gateway. Existing `~/.omp/agent/models.yml` and
`config.yml` are retained by default; use `--force` or `-Force` to back up and
replace both files.

On macOS or Linux, `config.sh` links the same tree to
`$XDG_CONFIG_HOME/nvim` (or `~/.config/nvim`).

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

When NVM is installed in `$NVM_DIR`, `~/.config/nvm`, or `~/.nvm`, startup
registers lightweight wrappers for `nvm`, `node`, `npm`, `npx`, and `corepack`.
NVM and its completions load on the first use of one of those commands. Run
`en_nvm` to initialize it explicitly in the current shell.

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
