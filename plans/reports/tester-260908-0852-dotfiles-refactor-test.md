# Dotfiles Refactor Test Report

Date: 2026-09-08
Environment: macOS Darwin, arm64, zsh, `/Users/vp/.dotfiles/tool`
Plan: `plans/2026-09-08-zhist-dotfiles-refactor/plan.md`

## Commands and results

- `bash tests/test-dotfiles.sh` — exit `0`; printed `PASS: dotfiles fixture tests`.
  Covered Bash/Zsh syntax, `.zshrc` preservation and idempotency, symlinked entrypoint
  relocation, link conflicts, existing `~/.config/nvim` preservation, native-history
  fallback, macOS/Homebrew dry-run provisioning, and unsupported package-manager
  diagnostics.
- `bash -n setup_zsh.sh install.sh config.sh scripts/dotfiles-lib.sh tests/test-dotfiles.sh`
  — exit `0`.
- `zsh -n zsh/config.zsh zsh/zenvs.zsh zsh/zaliases.zsh zsh/zfunctions.zsh` — exit `0`.
- `git diff --check` — exit `0`.
- Optional tools `shellcheck`, `shfmt`, `bats`, and `checkbashisms` — unavailable.

Additional temporary-fixture probes, with all fixture data removed afterward:

- Clean Zsh startup without optional tools — exit `0`; reported
  `HISTFILE=<temporary-home>/.zsh_history`, `SAVEHIST=100000`, and strategy `history`.
- Stubbed `zhist`/`fzf` startup — exit `0`; logged exactly `init -no-arrow-binds`.
- `config.sh` run twice against one temporary home — both exits `0`; second run reported
  four `Already linked` messages, preserved the Neovim marker, and created `0` root-owned
  fixture entries.
- Real interactive startup using a temporary `.zshrc` and a piped `zsh -i` loop — exit `0`;
  native history file was written and contained the probe command.
- Copied-clone relocation probe — `relocated_setup=pass`, `relocated_links=pass`; links
  resolved to the copied clone’s canonical path.
- `git ls-files vim nvim` checked for files still present in the working tree —
  `tracked_editor_files_present=0`; Git reports all editor files as deleted.

## Gaps

- Debian/Ubuntu APT paths, Linux architecture branches, and the real pinned zhist archive
  download/checksum/install were not executed on this macOS host.
- Real package installation, network cloning, font download, and `chsh` were not run;
  they are explicit state-changing opt-ins.
- Real zhist/fzf binaries and interactive Ctrl-R, arrow, vi-map, and autosuggestion
  behavior were not exercised; the guarded init command was validated with stubs.
- The deleted editor trees still have empty directories in this unstaged working tree,
  but no tracked editor files remain; Git will not retain empty directories in the final
  tree.

Status: DONE_WITH_CONCERNS
Summary: Focused fixture, syntax, whitespace, relocation, history, zhist-guard, and idempotent-link checks pass. Linux provisioning, real optional installs, and interactive keybinding behavior remain untested in this macOS-only environment.
Concerns/Blockers: No implementation failure reproduced; coverage gaps are environment- and side-effect-limited.
