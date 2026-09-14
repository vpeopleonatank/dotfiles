---
title: Repair zhist suggestions and picker query
date: 2026-09-14
summary: "Restore zhist-backed autosuggestions and seed the Ctrl-R picker from the command buffer."
---

# Repair zhist suggestions and picker query

## What happened
After zhist was enabled, zsh-autosuggestions stopped rendering suggestions even though `zhist search` returned matching history.

## Root cause
`zsh/config.zsh` assigned the zhist lookup result to `REPLY`; the installed zsh-autosuggestions fetch implementation reads the global `suggestion` variable.

## Decision
Assign the lookup result with `typeset -g suggestion=...` and add a fixture that exercises the strategy contract.
Retain zhist's generated picker, changing only its fzf invocation so Ctrl-R
starts with the current command-line buffer as its query.

## Verification
- Direct zsh-autosuggestions fetch with live zhist returned `git init`.
- The Ctrl-R fixture confirmed fzf receives `--query=git status`.
- `bash tests/test-dotfiles.sh` passed.

> Historical work record — not durable authority. Prefer docs/specs/ADRs for current decisions.
