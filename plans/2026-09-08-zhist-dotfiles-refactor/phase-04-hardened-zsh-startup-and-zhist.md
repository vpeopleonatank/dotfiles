# Phase 4 — Hardened zsh startup and zhist

## Context links

- [Plan overview](plan.md)
- [Phase 1 contract](phase-01-baseline-and-migration-contract.md)
- [zhist research](research/researcher-01-zhist.md)
- [Repository scout](scout/scout-01-repository.md)

## Overview

Use persistent native Zsh history until zhist initializes successfully, then make optional zhist initialization conditional and correctly ordered so a clean macOS/Linux shell starts quietly.

- Date: 2026-09-08
- Description: Complete guarded zhist integration and make portable zsh startup resilient.
- Priority: P2
- Implementation status: complete
- Review status: complete

## Key Insights

- `zenvs.zsh` contains the upstream-recommended zhist-compatible native history policy but is not sourced.
- `config.zsh` invokes `zhist` during autosuggestions and at startup even when no executable is installed.
- zhist must initialize after fzf/vi bindings; `-no-arrow-binds` retains native arrow behavior while preserving zhist `Ctrl-R`.
- Committed aliases/functions contain duplicates and host-specific assumptions that should not load universally.

## Requirements

- Source the portable history policy from the active startup chain once; retain in-session history and do not write legacy history files.
- Under the optional policy, require non-empty successful `zhist init -no-arrow-binds` output before switching autosuggestions and disabling native persistence; otherwise retain the native fallback with no errors.
- Initialize zhist after zsh-snap, zsh-vi-mode initialization, and fzf key bindings.
- Apply the selected arrow behavior; proposed default is `zhist init -no-arrow-binds`, with `Ctrl-R` deliberately owned by zhist.
- Move host-specific/personal exports and aliases into an explicitly opt-in, Git-ignored local file; guard optional commands in committed startup files.
- Deduplicate only overlapping aliases, styles, and function definitions in the affected startup files; preserve intentional workflows.

## Architecture

`zsh/config.zsh` loads portable common configuration, the history policy, plugins, safe command guards, and then an optional local layer. A single late zhist guard contains both its autosuggestion integration and init. `zsh/zenvs.zsh` becomes a portable environment/history layer or is split so personal host exports cannot affect every session.

## Related code files

- `zsh/config.zsh`
- `zsh/zenvs.zsh`
- `zsh/zaliases.zsh`
- `zsh/zfunctions.zsh`
- `.gitignore`
- `setup_zsh.sh`

## Implementation Steps

1. Separate portable history/options from host-local environment values and source the portable portion once.
2. Add one command-existence guard after the zsh-vi-mode/fzf callback; keep zhist autosuggestions and init inside it.
3. Use the selected zhist init flags and document key ownership, including picker-local `Ctrl-X` behavior.
4. Define the native autosuggestion fallback before the optional zhist override.
5. Remove duplicate active definitions and command calls that cannot work on a clean supported host; retain host-specific examples only in the ignored local layer or docs.
6. Provide a manual, idempotence-conscious legacy history import command that checks for a source file and empty/absent zhist store; never put import/deletion in startup.

## Todo list

- [x] Wire portable history policy into active startup.
- [x] Guard and order zhist init/autosuggestions.
- [x] Confirm and apply arrow-key policy.
- [x] Add opt-in ignored host-local configuration boundary.
- [x] Deduplicate affected startup definitions.
- [x] Document one-time zhist import and rollback.

## Success Criteria

- Zsh starts without errors when zhist, fzf, conda, Snap, CUDA, and personal directories are unavailable.
- With zhist installed, `Ctrl-R` opens zhist and autosuggestions query it; with zhist absent, suggestions/history remain usable.
- The selected arrow policy works in both normal/application cursor sequences and vi insert/command maps.
- Existing `~/.zsh_history` is neither imported repeatedly nor deleted.

## Risk Assessment

- Risk: init ordering lets a later plugin replace zhist bindings. Mitigation: add ordering tests and keep its guard at the verified final binding point.
- Risk: moving personal settings changes a user's machine. Mitigation: retain a documented opt-in local migration and do not infer host intent.

## Security Considerations

- Preserve the upstream `--` separator in `zhist search` so buffers beginning with `-` are not interpreted as options.
- Do not place history contents or host-local environment values under version control.

## Next steps

Provision zhist and other supported dependencies only through explicit platform-aware paths.
