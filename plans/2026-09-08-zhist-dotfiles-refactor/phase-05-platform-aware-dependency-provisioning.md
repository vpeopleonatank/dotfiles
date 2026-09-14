# Phase 5 — Platform-aware dependency provisioning

## Context links

- [Plan overview](plan.md)
- [Phase 1 contract](phase-01-baseline-and-migration-contract.md)
- [zhist research](research/researcher-01-zhist.md)
- [Repository scout](scout/scout-01-repository.md)

## Overview

Refactor dependency provisioning to honor the approved macOS/Linux package-manager matrix, make zhist availability match the chosen policy, and make every network or privilege operation explicit and verifiable.

- Date: 2026-09-08
- Description: Provision approved cross-platform dependencies and zhist safely.
- Priority: P2
- Implementation status: complete
- Review status: complete

## Key Insights

- Current `install.sh` uses APT, Snap, AppImage, Linux AMD64 downloads, and remote installer pipes without platform checks.
- Upstream supports zhist via Homebrew on macOS and Go install or Linux release assets on Linux; no distro package is documented.
- fzf `>=0.45` is a zhist dependency and should be verified before claiming zhist is ready.

## Requirements

- Support only the approved package managers and architectures; print a supported-manual-install path for all other systems.
- Provision zhist as required or best-effort according to Phase 1 policy, then verify `zhist` and compatible `fzf` are on `PATH`.
- Replace OS-specific binary/download assumptions with selected manager or architecture-validated release logic.
- Make optional tools independently selectable or safely skippable; no failed optional tool should leave later steps falsely reported as installed.
- Avoid invoking `pip`, `npm`, `cargo`, Go, Snap, or remote scripts until their prerequisites and user consent mode are satisfied.

## Architecture

The shared platform adapter exposes allowed package/back-end operations. `install.sh` organizes dependencies by required bootstrap versus optional developer tooling and records outcome status. zhist installation is one named capability with Homebrew and selected Linux implementation paths, followed by executable/version validation.

## Related code files

- `install.sh`
- `setup_zsh.sh`
- `README.md`
- `zsh/config.zsh`
- `zsh/zenvs.zsh`

## Implementation Steps

1. Convert package installation to platform/package-manager dispatch and reject unknown back ends before making changes.
2. Split prerequisite checks from installers; test command availability, writable local bins, network downloader, and selected architecture.
3. Add the selected zhist installation paths: Homebrew tap/formula on macOS; Go or verified release asset on Linux.
4. Verify zhist and fzf compatibility after install, and emit exact remediation commands on failure.
5. Replace unconditional download-and-execute patterns with downloads/checks that expose source, expected artifact, and exit status.
6. Reclassify Linux-only tools so macOS does not attempt APT, Snap, AppImage, `/snap`, or GNU/Linux paths.

## Todo list

- [x] Implement supported back-end dispatch.
- [x] Add zhist installer and post-install verification.
- [x] Gate Linux-only tooling by platform/architecture.
- [x] Add opt-in/skip behavior for optional tool groups.
- [x] Test network and privilege failure exits.

## Success Criteria

- macOS runs only approved Homebrew-compatible actions; Linux runs only the selected Linux path.
- zhist's installation outcome matches the declared policy and never makes shell startup fail when unavailable under the optional policy.
- Unsupported package managers and architectures exit safely with guidance and no guessed installation command.

## Risk Assessment

- Risk: latest remote artifacts change behavior. Mitigation: pin/check the selected release metadata or prefer the approved package manager.
- Risk: broad installer refactor breaks existing Linux users. Mitigation: stage prerequisite detection first and retain documented command-by-command entry points during migration.

## Security Considerations

- Validate download transport and artifact architecture before execution.
- Minimize privileged commands and never elevate an operation targeting `$HOME`.
- Never expose shell history or local configuration in installer diagnostics.

## Next steps

Validate all migrations in isolated homes and update the smallest owning documentation surfaces.
