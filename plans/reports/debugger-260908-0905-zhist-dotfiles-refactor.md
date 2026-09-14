# Root-cause audit — corrected zhist/dotfiles refactor

Date: 2026-09-08
Scope: corrected worktree revision, plan, README, fixtures, and prior review.

## Verification

- `bash tests/test-dotfiles.sh` — PASS.
- `bash -n setup_zsh.sh config.sh install.sh scripts/dotfiles-lib.sh` — PASS.
- `zsh -n zsh/*.zsh` — PASS.
- `git diff --check` — PASS.

## Findings

### P1 — Source symlinks are not constrained to the repository

`dotfiles_link` canonicalizes only the source parent directory and never resolves or verifies the final source path is inside `DOTFILES_ROOT` (`scripts/dotfiles-lib.sh:162-168`). A repository entry such as `kitty/kitty.conf` that is itself a symlink to an external path is accepted and linked into `$HOME`. This violates the phase security requirement to verify sources remain inside the repository and makes relocation safety dependent on repository contents remaining trusted.

### P1 — Foreign symlink destinations are silently accepted by optional installers

`setup_zsh.sh` treats a symlink to an external directory as an existing Powerlevel10k or zsh-snap installation because `[ -d "$target" ]` follows symlinks (`setup_zsh.sh:90-112`). Linux zhist similarly accepts a symlink to an executable because `[ -x "$target" ]` follows it (`install.sh:90-96`). These paths are not reported as conflicts, contrary to the documented conflict-preservation contract, and the zhist verification can subsequently use an externally selected executable. The font loop has the same follow-symlink behavior for existing font paths (`setup_zsh.sh:126-132`).

### P2 — APT dry-runs still require `sudo`

`package_install` checks for `sudo` before calling `dotfiles_run` (`install.sh:53-63`), and `setup_zsh.sh` does the same in its APT branch (`setup_zsh.sh:77-86`). On a supported Debian/Ubuntu host without `sudo`—including a root-owned environment where it is unnecessary—`--dry-run` exits before reporting the planned commands. No package change occurs, but the dry-run is not a complete/pure action preview.

### P2 — zhist initialization accepts empty successful output

`dotfiles_init_zhist` treats `zhist init` with exit status zero and empty output as successful because `eval ""` succeeds (`zsh/config.zsh:24-39`). It then switches autosuggestions to `zhist`, unsets `HISTFILE`, and sets `SAVEHIST=0`. If the executable is present but unusable or emits no initialization code, the native persistent-history fallback is lost. Require non-empty initialization code and/or verify the expected zhist state before changing history variables.

## Coverage gaps

The fixtures pass but do not exercise source symlinks, foreign optional-install symlinks, an APT dry-run without `sudo`, successful/empty/failing `zhist init`, the zsh-snap callback path, real zhist key maps, or import idempotence with a custom `ZHIST_FILE`. The previously fixed symlinked `.zshrc`, marker symlink, exact Linux ID, cheat path, font dry-run, and no-arrow-bind cases are covered or present in the corrected source.

Status: DONE_WITH_CONCERNS
Summary: The corrected revision passes the available fixture and syntax checks and fixes the prior reported regressions. Remaining concerns are source/destination symlink trust, incomplete APT dry-run behavior, and a zhist success predicate that can disable native history without proven initialization.
Concerns/Blockers: Address the two P1 symlink findings before treating the safety contract as complete; add focused fixtures for the listed zhist and APT paths.
