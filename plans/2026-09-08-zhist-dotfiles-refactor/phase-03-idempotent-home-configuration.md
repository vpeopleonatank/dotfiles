# Phase 3 — Idempotent home configuration

## Context links

- [Plan overview](plan.md)
- [Phase 1 contract](phase-01-baseline-and-migration-contract.md)
- [Repository scout](scout/scout-01-repository.md)

## Overview

Make configuration installation safe to rerun by centralizing home-directory link behavior, removing unnecessary privilege escalation, and leaving Vim/Neovim configuration to its external owner.

- Date: 2026-09-08
- Description: Add conflict-safe, idempotent home configuration links without repository-owned editor configuration.
- Priority: P2
- Implementation status: complete
- Review status: complete

## Key Insights

- Kitty linking is inverted: it attempts a link only when its destination already exists.
- Existing `nvim` file links conflict with the later link of the full `nvim` directory.
- `sudo ln` below `$HOME` creates avoidable ownership hazards and does not solve real target conflicts.

## Requirements

- Implement one link helper with outcomes for absent target, correct link, repository-managed replaceable link, foreign link, and regular file/directory.
- Never overwrite foreign/user targets without an explicit confirmed migration action selected in Phase 1.
- Never use `sudo` for any path owned by the current user under `$HOME`.
- Do not link or install Vim/Neovim configuration; preserve any existing external `~/.config/nvim` target.
- Preserve TPM, Kitty, tmux, lazygit, and snippets behavior within the chosen noninteractive policy.

## Architecture

`config.sh` consumes the shared path/platform layer and a declarative list of repository source-to-home targets. The link helper performs `readlink`/target comparison, constrains sources to the repository, and emits a human-readable status per target. Vim and Neovim have no source-to-home entries.

## Related code files

- `config.sh`
- `README.md`
- `vim/`
- `nvim/`
- `kitty/kitty.conf`
- `tmux/config.tmux`
- `lazygit/config.yml`
- `snippets/`

## Implementation Steps

1. Implement and unit-test the link state classifier using temporary homes.
2. Convert Kitty, tmux, lazygit, and snippets to declarative link requests.
3. Preserve external Vim/Neovim ownership and remove obsolete tracked editor trees.
4. Separate linking from plugin installation so conflicting files stop safely before any editor side effects.
5. Remove home-directory `sudo` use and add clear remediation output for root-owned pre-existing targets.

## Todo list

- [x] Add safe idempotent link helper.
- [x] Record and implement the external editor-ownership decision.
- [x] Convert configuration targets to the shared helper.
- [x] Separate/link-gate optional TPM installation.
- [x] Test foreign-link and regular-file conflict paths.

## Success Criteria

- Each target is created once, recognized on repeat, or left untouched with an actionable conflict message.
- No target below the test `$HOME` is created as root.
- Existing Neovim targets remain untouched and no editor links overlap.

## Risk Assessment

- Risk: a legacy user configuration is mistaken for a repository target. Mitigation: exact canonical target comparison and explicit migration approval.
- Risk: editor plugin steps hide link errors. Mitigation: stop before plugin commands on unresolved conflicts.

## Security Considerations

- Canonicalize and verify source paths remain inside the repository root before linking.
- Do not follow untrusted target symlinks while deciding whether to replace them.

## Next steps

Harden zsh startup so the safely installed source chain runs without optional dependency errors.
