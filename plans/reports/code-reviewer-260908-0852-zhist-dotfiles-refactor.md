# Code Review — zhist dotfiles refactor

Date: 2026-09-08
Scope: implementation diff, scout summary, plan acceptance criteria, changed callers/touchpoints

## Verification

- `bash tests/test-dotfiles.sh` — PASS.
- Bash and Zsh syntax checks in the fixture — PASS.
- `git diff --check` — PASS.
- ShellCheck was unavailable in the environment.
- The fixture covers relocated script entrypoints, normal link conflicts, native-history fallback, and a Darwin/Homebrew dry-run. It does not cover the Linux/Apt path, installed-zhist startup, symlinked `.zshrc`, broken marker symlinks, or interactive key behavior.

## Findings

### P1 — Existing `.zshrc` symlinks are replaced instead of preserved/reported

Location: `scripts/dotfiles-lib.sh:114-139`, called by `setup_zsh.sh:59-69`

`dotfiles_update_managed_block` accepts a symlink to a regular file because `-f` and `-w` follow the link, then atomically `mv`s a temporary file over the symlink. This removes the user’s existing `.zshrc` symlink even though the target contents remain unchanged. A direct fixture reproduced `zshrc_is_symlink=no` after setup. That violates the requirement to preserve/report conflicting home targets.

Fix: reject an existing symlink before the temporary-file path, or require an explicit migration action before replacing it.

### P1 — A broken `tmux_no_auto_restore` symlink can redirect a write outside `$HOME`

Location: `config.sh:44-50`

The marker check uses `-e`, which is false for a dangling symlink, and then `: > "$HOME/tmux_no_auto_restore"` follows that symlink. A direct fixture created the symlink target outside the home marker path. This both fails conflict preservation and can create/overwrite an unintended destination.

Fix: check `-L` before `-e`; report and retain any symlink rather than redirecting the shell redirection.

### P1 — Platform detection provisions unsupported Linux derivatives

Location: `scripts/dotfiles-lib.sh:48-55`, consumed by `install.sh:50-68` and `setup_zsh.sh:72-82`

The support contract is Debian/Ubuntu Linux, but the detector accepts any distribution whose `ID_LIKE` contains `debian` or `ubuntu`, including derivatives such as Linux Mint. It then permits APT operations. `ID_LIKE` is not an exact Debian/Ubuntu identity check, so unsupported hosts can receive package changes despite the documented bounded matrix.

Fix: require `ID` to be exactly `debian` or `ubuntu` for automated provisioning; use `ID_LIKE` only in diagnostics.

### P1 — Relocated clones still break the active Cheat configuration

Location: `cheat/conf.yml:56-58`, activated through `zsh/zenvs.zsh:3`

`zenvs.zsh` now resolves `CHEAT_CONFIG_PATH` from `DOTFILES_ROOT`, but the loaded config still hard-codes `/home/vpoat/.dotfiles/tool/cheat/cheatsheets/personal`. On a relocated clone, the personal cheatpath points to the old machine-specific repository location, so the relocated setup is not fully functional.

Fix: make the personal path relative to the resolved repository root or make it an explicit local override instead of a fixed absolute path.

### P1 — zhist presence can disable persistent history before zhist is initialized

Location: `zsh/zenvs.zsh:46-53`, `zsh/config.zsh:44-84`

`zenvs.zsh` unsets `HISTFILE` and sets `SAVEHIST=0` solely when both `zhist` and `fzf` are present. Initialization is deferred to `zvm_after_init` when zsh-snap is present. If zsh-snap is present but zsh-vi-mode does not complete and invoke that callback (for example, an unavailable or failed plugin load), no zhist init runs while native persistence has already been disabled. The optional-history contract requires native persistence whenever zhist is not actually usable.

Fix: keep native history enabled until guarded zhist initialization succeeds, or make the history policy depend on the same successful initialization state.

### P1 — The documented one-time import guard ignores `ZHIST_FILE`

Location: `README.md:73-79`

The migration command checks only the default `${XDG_DATA_HOME:-$HOME/.local/share}/zhist/history.jsonl`. zhist supports overriding its store with `ZHIST_FILE`; with a non-empty custom store and no default store, the documented condition remains true and a repeat import can duplicate records.

Fix: use `${ZHIST_FILE:-${XDG_DATA_HOME:-$HOME/.local/share}/zhist/history.jsonl}` in the guard, or explicitly document that custom stores require an equivalent guard.

### P2 — Dry-run font setup still creates a home directory

Location: `setup_zsh.sh:110-123`

`install_fonts` runs `mkdir -p "$fonts_dir"` before checking `DOTFILES_DRY_RUN`. The documented `--dry-run` contract says it reports writes without changing the host, but it creates the font directory even when no download is performed.

Fix: perform the dry-run branch before `mkdir -p`, while still reporting the planned directory and files.

### P2 — Loaded utility functions retain non-portable macOS command flags

Location: `zsh/zfunctions.zsh:9-12`, `zsh/zaliases.zsh:27-32`

The supported matrix includes macOS, but the loaded `show-process` function invokes GNU `ps --sort`, and `tl` invokes GNU `xargs -r`; BSD macOS implementations do not support those flags. These functions fail when used on a supported macOS host even though startup syntax passes.

Fix: use portable command forms or guard platform-specific implementations with a macOS-compatible alternative.

## Acceptance criterion summary

- Relocated clone: FAIL for the active Cheat personal path; script root resolution itself passes.
- Existing `.zshrc` and conflicting targets: FAIL for symlinked `.zshrc` and dangling marker symlink; ordinary file/foreign-link fixtures pass.
- Repeatable setup/link actions and privilege safety: PARTIAL; normal paths use user-owned writes, but the dangling-symlink write is unsafe.
- Vim/Neovim ownership: PASS in the diff and fixture; tracked trees are deleted and the existing `~/.config/nvim` fixture remains untouched.
- Optional zhist/native fallback: PARTIAL; absent-zhist fallback passes, but the deferred-init path can disable native persistence prematurely.
- Supported provisioning and pinned Linux zhist assets: PARTIAL; pinned v1.2.1 asset names/checksums exist, but platform detection accepts unsupported derivatives and the test suite does not exercise the Linux path.
- Explicit package installation and `chsh`: PASS; actions are option-gated and `chsh` rejects noninteractive use.
- Focused fixtures and syntax: PASS; ShellCheck unavailable and the untested cases are listed above.

Status: DONE_WITH_CONCERNS
Summary: The focused tests and syntax checks pass, but the implementation has confirmed conflict-safety, relocation, platform-gating, zhist persistence, documentation, and macOS portability defects.
Concerns/Blockers: Fix the six P1 findings before treating the implementation as acceptance-complete; P2 findings should be addressed before release.
