# Phase 2 — Portable safe bootstrap

## Context links

- [Plan overview](plan.md)
- [Phase 1 contract](phase-01-baseline-and-migration-contract.md)
- [Repository scout](scout/scout-01-repository.md)

## Overview

Refactor the shell bootstrap entry point so it resolves its actual repository location, detects the supported platform safely, and adds a managed source entry to `.zshrc` without destroying existing user configuration.

- Date: 2026-09-08
- Description: Make zsh bootstrap relocatable, platform-aware, and non-destructive.
- Priority: P2
- Implementation status: complete
- Review status: complete

## Key Insights

- The current `.zshrc` redirect is destructive and records a fixed clone location.
- macOS cannot use the current GNU `sed -i` invocation unchanged.
- Changing the login shell and downloading fonts/plugins are user-visible operations that need preconditions and idempotency.

## Requirements

- Resolve the repository root from the executing script path, including symlink-safe behavior required by the selected shell contract.
- Replace overwrite behavior with one uniquely delimited managed source block; update that block idempotently while preserving all other bytes in `.zshrc`.
- Refuse or clearly report unreadable/unwritable `.zshrc` and do not leave partially written files.
- Use platform-specific font locations/cache refresh commands only when supported and available.
- Do not make `chsh` mandatory in a noninteractive run; report the next action if it needs a terminal/password.

## Architecture

The shared foundation exposes root/path, platform, diagnostic, and atomic managed-file helpers. `setup_zsh.sh` becomes an orchestrator that calls those helpers, performs only selected bootstrap work, and uses a marker block that sources the root-resolved `zsh/config.zsh` path.

## Related code files

- `setup_zsh.sh`
- `README.md`
- `.gitignore`
- `zsh/config.zsh`

## Implementation Steps

1. Add and source a narrow Bash helper module from setup/config/install entry points, with safe root resolution and OS detection.
2. Implement an atomic managed-block updater for `.zshrc`; preserve legacy content, avoid duplicate blocks, and print the exact file changed.
3. Gate package installation, default-shell changes, powerlevel10k clone, fonts, and cache refresh behind command/platform/precondition checks.
4. Replace GNU-specific text edits with portable shell logic or platform-aware helpers.
5. Update setup instructions to explain the first-run prompt and retained user configuration.

## Todo list

- [x] Implement root and platform helpers.
- [x] Add atomic managed `.zshrc` source-block migration.
- [x] Make bootstrap actions idempotent and platform-gated.
- [x] Document interactive/default-shell behavior.

## Success Criteria

- Running setup from any clone location preserves existing `.zshrc` content and produces one correct managed source block.
- A second run performs no destructive replacement and reports already-satisfied steps.
- macOS and Linux neither execute another platform's commands nor require GNU `sed` compatibility by accident.

## Risk Assessment

- Risk: marker parsing corrupts an unusual `.zshrc`. Mitigation: write a temporary sibling file, validate it, and rename only on success.
- Risk: `chsh` changes a login shell unexpectedly. Mitigation: make it opt-in or interactive according to Phase 1 policy.

## Security Considerations

- Quote all paths and reject unsafe write destinations.
- Avoid piping remote content directly into a privileged shell; make download origin and failure visible.

## Next steps

Use the same root and conflict primitives to make home-directory links safe.
