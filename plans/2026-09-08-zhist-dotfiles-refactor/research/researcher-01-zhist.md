# zhist integration research

Researched 2026-09-08 against upstream `main` and release `v1.2.1` (published 2026-09-07).

## Evidence and conclusions

- zhist replaces the *persistent* zsh history file with a JSONL store, retaining native history only in memory for same-session line stepping and `!` expansion. The repository’s `zenvs.zsh` already exactly matches upstream's recommended `HISTFILE`/`HISTSIZE`/`SAVEHIST` and options; keep it, and do not enable `SHARE_HISTORY`, `INC_APPEND_HISTORY`, or `EXTENDED_HISTORY`. [README](https://github.com/overflowy/zhist/blob/main/README.md#recommended-zsh-history-settings)
- Default store is `$HOME/.local/share/zhist/history.jsonl`; `ZHIST_FILE` overrides it. Preview state follows `XDG_STATE_HOME` or `$HOME/.local/state`. This shared dotfiles setup needs no OS-specific storage path unless cross-host history sharing is intended. [source](https://github.com/overflowy/zhist/blob/main/main.go#L21-L27) [source](https://github.com/overflowy/zhist/blob/main/main.go#L337-L340)
- macOS: upstream recommends `brew install overflowy/tap/zhist`; Homebrew brings `fzf` (minimum `0.45`) as a dependency. [README](https://github.com/overflowy/zhist#install)
- Linux: upstream documents `go install github.com/overflowy/zhist@latest` or a zinit GitHub-release binary; the current `v1.2.1` assets include Linux amd64 and arm64 tarballs, so a package-manager-independent release install is viable. No apt/dnf/pacman package is documented. [README](https://github.com/overflowy/zhist#install) [v1.2.1 assets](https://github.com/overflowy/zhist/releases/tag/v1.2.1)
- `zinit ice from"gh-r" as"program"; zinit light overflowy/zhist` installs a binary. In contrast, `znap source overflowy/zhist` only sources `zhist.plugin.zsh`; it does **not** install the executable. [README](https://github.com/overflowy/zhist#setup) [plugin](https://github.com/overflowy/zhist/blob/main/zhist.plugin.zsh)
- The supplied zsh-snap plugin uses safe, Zsh-native detection: `(( $+commands[zhist] )) && eval "$(zhist init)"`. Mirror this guard for any manual integration. Do not use the present unconditional `eval "$(zhist init)"` in `config.zsh`, which emits an error when an OS lacks zhist. [plugin](https://github.com/overflowy/zhist/blob/main/zhist.plugin.zsh) [config](/Users/vp/.dotfiles/tool/zsh/config.zsh)
- The present autosuggestion function calls `zhist search` from `zvm_after_init`, but activates the `zhist` strategy even if the command is absent. Define/activate it only within the same command-existence guard; otherwise preserve `zsh-autosuggestions`' normal history strategy. Upstream's `--` is important so a buffer beginning with `-` is not parsed as an option. [README](https://github.com/overflowy/zhist#inline-suggestions)
- zhist must initialize after plugins binding `ctrl-r` or arrows because the last bind wins. It binds `ctrl-r` always, and by default arrows (normal + application cursor sequences); its own picker reserves `ctrl-g`, `ctrl-d`, `ctrl-x`, `tab`, and `ctrl-/` *inside fzf*. [README](https://github.com/overflowy/zhist#keys) [init source](https://github.com/overflowy/zhist/blob/main/main.go#L376-L386)
- Existing config configures fzf and `zsh-autosuggestions` in `zvm_after_init`; zhist initialization should therefore occur only after zsh-snap loading, zsh-vi-mode completion, and that callback's fzf bindings. Use guarded manual `eval "$(zhist init -no-arrow-binds)"` at the end of the callback (or a confirmed post-callback hook), not `znap source overflowy/zhist`, so arrow behavior remains native/vi-mode compatible. `ctrl-r` then remains zhist's deliberate override. `-no-arrow-binds` is upstream-supported. [README](https://github.com/overflowy/zhist#compatibility-notes) [init source](https://github.com/overflowy/zhist/blob/main/main.go#L389-L395)
- The existing `run-again` binds `ctrl-x` only in ZLE's `viins`/`vicmd` maps; it does not conflict with zhist's fzf-picker `ctrl-x` deletion binding. Still, call this out in migration notes because `ctrl-x` has different meaning while the picker is open. [config](/Users/vp/.dotfiles/tool/zsh/config.zsh) [README](https://github.com/overflowy/zhist#keys)
- Migration is one-time: run `zhist import ~/.zsh_history` only after confirming a legacy file exists and the target store is empty/absent. Imported records omit directory/status/duration, so they show blank directory and never render failure-red. Do not rerun import or delete the legacy file as part of shell startup. [README](https://github.com/overflowy/zhist#setup)

## Recommended plan actions

1. Add OS provisioning: Homebrew tap formula on macOS; Linux Go install or verified `v1.2.1` release asset for amd64/arm64, with `fzf >=0.45` available on PATH.
2. Retain the native history block in `zsh/zenvs.zsh`; ensure it is sourced by the active startup chain before normal interactive use.
3. Replace unconditional init with a single `(( $+commands[zhist] ))` guard placed after zsh-snap, `zvm_after_init`, and fzf binding setup. Choose `zhist init -no-arrow-binds` to preserve existing up/down behavior.
4. Scope the custom autosuggestion strategy and `ZSH_AUTOSUGGEST_STRATEGY=(zhist)` inside that guard, preserving fallback behavior when absent.
5. Document/run a one-off, idempotence-conscious legacy import; smoke-test `ctrl-r`, empty-buffer up/down, vi insert/command maps, autosuggestions, and failed-command rendering on both OSes.

## Unresolved questions

- Is zhist intended to be mandatory on every managed host, or should unsupported/unprovisioned hosts retain standard zsh history without startup warnings?
- Should arrow keys intentionally open zhist's picker, or should the recommended `-no-arrow-binds` preserve the current native/vi-mode behavior?
- Is existing `~/.zsh_history` an EXTENDED_HISTORY-formatted file worth importing, and should each host retain an independent zhist database or share one?

Status: DONE
Summary: Current upstream requirements and repository integration gaps are documented with an OS-aware, guarded initialization recommendation.
