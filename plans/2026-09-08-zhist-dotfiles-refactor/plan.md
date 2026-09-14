---
title: Safe macOS/Linux dotfiles refactor and zhist completion
description: Make bootstrap, linking, shell startup, and zhist integration relocatable, idempotent, and safe for existing user configurations.
status: complete
priority: P2
effort: 15d
branch: master
tags: [dotfiles, zsh, macos, linux, zhist, migration]
date: 2026-09-08
created: 2026-09-08
---

# Safe macOS/Linux dotfiles refactor and zhist completion

## Outcome

Deliver a relocatable macOS/Linux setup whose scripts preserve existing user configuration, never require root for files below `$HOME`, leave editor configuration to its external owner, and make zhist usable without breaking machines where it is not installed.

## Scope and guardrails

- Refactor only the current bootstrap/configuration flow and zsh startup related to portability, idempotency, and zhist.
- Preserve user-managed `.zshrc`, `.p10k.zsh`, history files, plugin data, fonts, and existing configuration targets unless an explicit migration action is confirmed.
- Stop managing Vim and Neovim from this repository. Remove the tracked `vim/` and `nvim/` trees and the associated link/plugin-install behavior during implementation, without changing `~/.config/nvim` or the external configuration repository.
- Do not add unrelated tooling, rewrite personal workflow aliases, introduce cross-host history synchronization, or delete legacy history automatically.
- Default to clear diagnostics and a no-change exit for platform, privilege, network, or destination conflicts that cannot be handled safely.

## Validated implementation decisions

| Decision | Confirmed choice | Why it matters |
| --- | --- | --- | --- |
| zhist policy | Optional, with persistent native Zsh history when zhist is absent | Prevents an unprovisioned host from losing history between sessions. |
| arrow behavior | Native and vi-mode arrows via `zhist init -no-arrow-binds` | Prevents zhist from replacing normal and application cursor bindings. |
| editor configuration | No Vim/Neovim ownership in this repository | The active Neovim configuration is maintained in another repository. |
| supported systems | macOS with Homebrew; Debian/Ubuntu Linux with APT; amd64 and arm64 | Defines a bounded, testable support contract. Other systems receive no-change manual guidance. |
| Linux zhist source | Pinned, architecture-validated release assets | Avoids an unbounded `@latest` install and does not require Go solely for zhist. |
| state-changing setup | Package installation and `chsh` are opt-in | Avoids surprise privilege prompts and broad dependency changes. |
| host-specific settings | Manual migration to an ignored local configuration file | Avoids guessing which personal paths and exports remain valid on each host. |

## Phases

1. [Phase 1 — Baseline and migration contract](phase-01-baseline-and-migration-contract.md) — 2d
2. [Phase 2 — Portable safe bootstrap](phase-02-portable-safe-bootstrap.md) — 3d
3. [Phase 3 — Idempotent home configuration](phase-03-idempotent-home-configuration.md) — 3d
4. [Phase 4 — Hardened zsh startup and zhist](phase-04-hardened-zsh-startup-and-zhist.md) — 3d
5. [Phase 5 — Platform-aware dependency provisioning](phase-05-platform-aware-dependency-provisioning.md) — 2d
6. [Phase 6 — Validation, migration guidance, and documentation](phase-06-validation-migration-and-documentation.md) — 2d

## Acceptance criteria

- A relocated clone works on supported macOS and Linux hosts without hard-coded repository paths.
- Existing `.zshrc` contents and conflicting home targets are retained and reported rather than overwritten.
- Setup and link actions are safely repeatable, make no root-owned files under `$HOME`, and have a documented rollback path.
- The repository no longer installs or links Vim/Neovim configuration, and it does not alter the externally managed `~/.config/nvim` target.
- zhist is provisioned according to the selected support policy, initializes only when installed, preserves the selected arrow policy, and has a one-time guarded import procedure.
- Clean interactive zsh sessions without optional tools or personal Linux paths complete silently; when zhist is absent, native history remains persistent across sessions.

## Verification strategy

- Syntax-check Bash/Zsh and run fixture-based temporary-`HOME` tests for bootstrap and link conflict cases.
- Exercise supported package-manager/platform paths with command stubs before real installs.
- Smoke-test clean macOS and Linux interactive zsh sessions with and without zhist/fzf and verify `Ctrl-R`, arrows, vi maps, suggestions, and history import safety.

## Validation Summary

**Validated:** 2026-09-08  
**Questions asked:** 1 bundled confirmation covering 7 decision points

### Confirmed Decisions

- zhist remains optional; native persistent Zsh history is the fallback when it is unavailable.
- zhist does not own arrow keys; native and vi-mode behavior is preserved.
- Vim and Neovim configuration are removed from this repository during implementation; the external configuration and current home target remain untouched.
- Supported automated provisioning is limited to Homebrew on macOS and APT on Debian/Ubuntu Linux, on amd64 and arm64.
- Linux zhist installation uses a pinned, architecture-validated release asset.
- Package installation and login-shell changes require explicit opt-in.
- Host-specific settings move only through a documented manual migration.

### Action Items

- [x] Revise Phase 3 to remove Vim/Neovim link ownership, plugin installation, and migration work; include deletion of the tracked `vim/` and `nvim/` trees while preserving external/home configuration.
- [x] Revise Phase 4 so the native fallback uses a persistent history file when zhist is absent; the current unconditional `unset HISTFILE` requirement contradicts the confirmed fallback.
- [x] Revise Phases 1, 2, 5, and 6 to encode the confirmed platform matrix, pinned Linux asset policy, explicit opt-in boundary, and manual host-local migration.
- [x] Recalculate phase effort and verification cases after editor configuration leaves scope.

**Recommendation:** Implementation is complete. Retain the documented environment-dependent validation gaps before claiming full supported-platform verification.

## Risks and rollback

- Preserve-before-replace semantics and managed marker blocks make `.zshrc` migration reversible.
- Keep the legacy history file and avoid startup import/deletion; remove the managed zhist init block to revert to native history.
- Link changes must back up or leave conflicts untouched; rollback restores only links created by this repository.

## Finalization Status

Implementation is complete for bootstrap, home links, zsh startup, zhist, and
platform provisioning. All prior P1/P2 findings are fixed.

Focused validation completed on 2026-09-08 with `bash tests/test-dotfiles.sh`,
Bash/Zsh syntax checks, `git diff --check`, and installed/absent/empty-init
zhist smoke checks. The suite covers managed-block preservation/idempotence,
relocated entrypoints, source and destination symlink safety, malformed
markers, link conflicts, external Neovim preservation, native history
fallback, zhist initialization, macOS and Debian/Ubuntu dispatch stubs,
dry-run purity, and unsupported-host no-change paths.

Environment-limited follow-up remains for real Debian/Ubuntu APT/download/
privilege execution, a no-sudo Linux runtime, interactive zhist key behavior,
and real disposable history-import idempotence and rollback.
