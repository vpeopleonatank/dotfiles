# Phase 1 — Baseline and migration contract

## Context links

- [Plan overview](plan.md)
- [Repository scout](scout/scout-01-repository.md)
- [zhist research](research/researcher-01-zhist.md)

## Overview

Establish the supported-host contract and a reproducible baseline before modifying scripts or startup files. Resolve choices that change user behavior rather than encoding assumptions into the refactor.

- Date: 2026-09-08
- Description: Define the migration contract, supported-host boundaries, and safe conflict policy.
- Priority: P2
- Implementation status: complete
- Review status: partial

## Key Insights

- Current scripts assume APT, Snap, GNU `sed`, Linux binaries, and `$HOME/.dotfiles/tool`.
- `setup_zsh.sh` replaces `.zshrc`; `config.sh` has overlapping Neovim links and uses `sudo` in `$HOME`.
- zhist needs a binary plus late, guarded initialization; current startup calls it unconditionally.

## Requirements

- Record the four decisions in the overview: zhist policy, arrow behavior, Neovim owner, and package-manager support.
- Define supported architectures for Linux release assets if Go is not selected as the only Linux path.
- Define noninteractive behavior, privilege prompts, network failure behavior, and dry-run/reporting expectations.
- Inventory current user-owned versus repository-owned targets and establish that unresolved conflicts are never overwritten automatically.

## Architecture

Use a small Bash-compatible shared foundation for repository-root resolution, OS/package-manager detection, command availability, managed-block updates, and link conflict classification. Keep zsh-only behavior in the zsh layer; use local ignored configuration for host-specific settings rather than machine detection scattered through committed files.

## Related code files

- `README.md`
- `setup_zsh.sh`
- `install.sh`
- `config.sh`
- `.gitignore`
- `zsh/config.zsh`
- `zsh/zenvs.zsh`
- `zsh/zaliases.zsh`
- `zsh/zfunctions.zsh`

## Implementation Steps

1. Capture a command/output baseline for script syntax and a clean interactive zsh invocation on each target platform.
2. Write the support matrix and conflict policy in the owning setup documentation.
3. Select the migration and ownership decisions, including explicit fallback behavior when zhist or a package manager is unavailable.
4. Identify portable/local configuration boundaries and an ignored filename that does not silently replace existing user files.
5. Define fixture cases for pre-existing `.zshrc`, history, links, regular files, and an arbitrary clone path.

## Todo list

- [x] Approve the support and ownership decisions.
- [ ] Capture macOS and no-sudo Linux baseline observations.
- [x] Define reversible migration and conflict-reporting policy.
- [x] Define test fixtures and success outputs.

## Success Criteria

- Every later phase has an accepted behavior contract for material user choices.
- The implementation can distinguish repository-managed state from user state without content heuristics.
- Unsupported systems have a safe, documented no-change outcome.

## Risk Assessment

- Risk: choosing a Neovim owner late can leave migration code ambiguous. Mitigation: block link implementation until selected.
- Risk: treating zhist as mandatory silently changes shell behavior. Mitigation: make the policy an explicit decision and test its fallback.

## Security Considerations

- Do not log environment secrets while collecting baseline output.
- Treat downloaded installers, package-manager execution, and `chsh` as explicit state-changing operations with observable failure paths.

## Next steps

Proceed to the shared portable bootstrap foundation after the decision record is accepted.
