# Technical Journal: zhist Dotfiles Refactor

Date: 2026-09-08 (Asia/Ho_Chi_Minh)  
Environment: macOS Darwin, zsh

## Outcome

Completed the dotfiles refactor for relocatable, idempotent, conflict-safe macOS and Debian/Ubuntu setup. Bootstrap and link scripts now preserve existing user configuration, avoid implicit package/network/root actions, leave Vim/Neovim ownership external, and provide persistent native Zsh history when optional zhist is unavailable. The repository documents migration, host-local configuration, and rollback procedures.

## Key decisions

- zhist is optional; native `~/.zsh_history` remains the fallback.
- zhist initializes with `-no-arrow-binds`; native and vi-mode arrow behavior remains intact.
- Linux zhist installation uses a pinned, architecture-validated `v1.2.1` release asset.
- Automated provisioning is limited to Homebrew on macOS and APT on Debian/Ubuntu, amd64/arm64.
- Package installation, network clones/downloads, and `chsh` require explicit opt-in.
- Tracked Vim/Neovim trees and editor link/plugin management were removed; existing external editor configuration is preserved.
- `.zshrc` updates use one managed block; conflicts, foreign symlinks, and malformed markers are retained and reported.

## Validation

- `bash tests/test-dotfiles.sh` — PASS; fixture coverage includes relocation, managed-block preservation/idempotence, symlink and link conflicts, external Neovim preservation, native-history fallback, zhist initialization, platform dispatch, dry-run purity, and unsupported-host no-change behavior.
- `bash -n setup_zsh.sh config.sh install.sh scripts/dotfiles-lib.sh` — PASS.
- `zsh -n zsh/config.zsh zsh/zenvs.zsh zsh/zaliases.zsh zsh/zfunctions.zsh` — PASS.
- `git diff --check` — PASS.
- zhist smoke checks for installed, absent, and empty-init cases — PASS; the focused suite also passed macOS and Debian/Ubuntu command-dispatch stubs.

## Environment-limited follow-ups

- Exercise real Debian/Ubuntu APT, release download, and privilege execution.
- Validate a Linux runtime without `sudo`.
- Verify interactive zhist key behavior, including `Ctrl-R`, arrows, vi maps, and `Ctrl-X`.
- Run disposable real history-import tests for idempotence and rollback, while retaining the legacy history file.

Status: DONE_WITH_CONCERNS
Summary: The refactor and focused macOS validation are complete, with documented platform and interactive-history checks still requiring environment-specific execution.
Concerns/Blockers: Full supported-platform verification remains environment-limited as listed above.
