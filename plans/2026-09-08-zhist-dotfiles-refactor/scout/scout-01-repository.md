# Repository Scout: zsh Bootstrap Refactor

## Scope and ownership
- `README.md:4` defines the three-step install flow: `setup_zsh.sh`, `install.sh`, then `config.sh`.
- `setup_zsh.sh` owns package installation, default shell, `~/.zshrc`, Powerlevel10k, and fonts.
- `config.sh` owns home-directory links, Neovim plugin installation, TPM, and `~/.tmux.conf`.
- `zsh/config.zsh` owns interactive plugins, aliases/functions, zoxide, and zhist initialization. It currently does **not** load `zsh/zenvs.zsh` (`zsh/config.zsh:115`).
- `zsh/zenvs.zsh` owns history/options and machine environment variables but is inactive. Commit `d18a609` moved history behavior there while also adding zhist use to `config.zsh`.

## Priority findings
1. **P0 — bootstrap destroys an existing shell configuration.** `setup_zsh.sh:10` overwrites `~/.zshrc` unconditionally with a source line. It also hard-codes `$HOME/.dotfiles/tool`, which conflicts with the README clone location if the repository is elsewhere.
2. **P0 — configuration linking is unsafe and not idempotent.** `config.sh:9-11` attempts the Kitty link only when the destination file already exists, so it fails rather than installs. Links in `config.sh:21-24,43,45` use `sudo` in the user's home and fail on rerun or overwrite/conflict conditions. The final `nvim` directory link overlaps prior links inside `~/.config/nvim`, yielding ambiguous destination behavior.
3. **P0 — all installers are Linux-specific and perform unguarded privileged/network actions.** `setup_zsh.sh:3-4` and `install.sh:55,66` require APT/Snap; `install.sh:14` fetches a Linux AMD64 binary; `setup_zsh.sh:18` uses GNU `sed -i`, which is incompatible with macOS syntax. Both scripts download and execute remote installers without platform/command checks.
4. **P1 — shell startup has a missing dependency path.** `zsh/config.zsh:44-49,166` calls `zhist` without verifying it exists, but `install.sh` does not install it. A missing binary emits startup/widget errors. The intended no-file-history settings in `zenvs.zsh:45-55` do not apply because its source is commented out.
5. **P1 — repo-root assumptions are duplicated.** `setup_zsh.sh:10`, `config.sh:10,21-24,37,43,45`, and `zsh/config.zsh:113-115` embed `$HOME/.dotfiles/tool`; `zaliases.zsh:17` embeds it again. These prevent relocatable clones and make a partial migration inconsistent.
6. **P1 — shell definitions conflict or duplicate.** `zaliases.zsh:4,28` defines `lg` twice. `zaliases.zsh:50-74` duplicates `get_compile_command`, `show-process`, `sync_jupyter`, and `source_openvino` in `zfunctions.zsh:1-25`. `config.zsh:8,24` and `config.zsh:9,26` duplicate zstyles, with the later values winning; `zenvs.zsh:16,67` sets two different FZF default commands.
7. **P1 — personal/Linux assumptions load for every zsh session.** `zaliases.zsh:12-13,20-27,33-34` embeds personal paths plus APT, GNU netstat, and X11 clipboard commands. `zfunctions.zsh:9-12,21-24,68-71` relies on GNU `ps`/xargs and a fixed OpenVINO path. `zenvs.zsh:3,23-33,78` assumes Anaconda, Go, Snap, Linux JVM, IBus, and Android locations.
8. **P2 — generated/vendored-artifact ownership is unclear.** `.gitignore:1-3` ignores only Git metadata, an undo directory, and `*.zwc`. Tracked `nvim/lazy-lock.json` is a generated dependency lock and `fonts/MesloLGS_NF.zip` is a vendored binary archive; retain only if their update/ownership policy is deliberate. User-generated `~/.p10k.zsh`, cloned plugins, fonts, and plugin data remain outside repo ownership.

## Minimal refactor boundaries
1. **Foundation:** add one shell-compatible path/platform helper used by the three scripts; resolve repo root from each script's own location, not a fixed clone path. Define supported macOS/Linux package-manager behavior and noninteractive/privileged boundaries.
2. **Safe bootstrap:** replace `.zshrc` overwrite with a clearly delimited managed source block that preserves user content. Keep portable startup in `zsh/config.zsh`; put machine-specific settings in an explicitly opt-in local file ignored by Git.
3. **Configuration links:** choose one Neovim configuration owner (`vim/` legacy links or `nvim/` directory). Centralize a link helper: no-op for the desired link, refuse/report real files or foreign links, never use `sudo` for paths under `$HOME`.
4. **Startup cleanup:** make zhist optional or install/document it as required; intentionally wire the no-file-history policy into the active startup path. Deduplicate functions/aliases/styles and guard optional commands by `command -v`.

## Suggested validation
- Run `bash -n setup_zsh.sh config.sh install.sh` and `zsh -n zsh/*.zsh` (both currently pass).
- Test with temporary `HOME` values and stubbed package/network/chsh commands: preserve a pre-existing `.zshrc`, install only one managed block, and verify a relocated clone works.
- Exercise link helper cases: absent target, correct existing link, foreign link, and regular file; assert no root-owned files under the test home.
- Smoke-test clean macOS and Linux zsh sessions without zhist, fzf, exa, conda, Snap, CUDA, or personal directories; startup must be silent and retain core completion/history behavior.
- Add ShellCheck where compatible, plus a macOS/Linux CI matrix before changing installer semantics.

## Unresolved questions
- Is zhist mandatory, optional with native history fallback, or supplied outside this repository?
- Should existing user `.zshrc` content be preserved verbatim, migrated into a local file, or require explicit opt-in?
- Which Neovim tree is authoritative: `vim/` or `nvim/`?
- Are Homebrew on macOS and APT on Linux the intended supported package managers, and should installers remain opt-in per tool?

