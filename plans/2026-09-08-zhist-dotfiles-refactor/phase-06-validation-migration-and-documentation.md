# Phase 6 — Validation, migration guidance, and documentation

## Context links

- [Plan overview](plan.md)
- [Repository scout validation suggestions](scout/scout-01-repository.md)
- [zhist migration research](research/researcher-01-zhist.md)

## Overview

Prove that the refactor is safe on both platforms and publish only the operational guidance needed to install, migrate, troubleshoot, and roll back the changed behavior.

- Date: 2026-09-08
- Description: Validate migration safety and document installation, history migration, and rollback.
- Priority: P2
- Implementation status: complete
- Review status: complete

## Key Insights

- Syntax checks alone cannot detect destructive `.zshrc` replacement, foreign-link overwrite, or incorrect key bindings.
- Temporary-home fixtures can test migration safety without affecting the maintainer's machine.
- zhist import is deliberately lossy for directory/status/duration metadata and must remain manual and one-time.

## Requirements

- Test all scripts with temporary `HOME` values and stubbed package/network/`chsh` operations.
- Cover absent target, correct link, foreign link, regular file, pre-existing `.zshrc`, relocated clone, repeat execution, and root-owned conflict reporting.
- Validate interactive zsh behavior on supported macOS/Linux matrices both with and without zhist/fzf.
- Update `README.md` or the smallest owning documentation with support matrix, safe migration, external Vim/Neovim ownership, optional local config, zhist install/import, key behavior, and rollback instructions.
- Do not claim support for untested package managers, architectures, or external tools.

## Architecture

Use lightweight shell fixtures and command stubs rather than real package installs. A CI matrix, if repository automation is adopted in scope, runs syntax/static checks and fixture tests on macOS and Linux; manual smoke tests cover terminal-dependent keyboard behavior.

## Related code files

- `README.md`
- `setup_zsh.sh`
- `install.sh`
- `config.sh`
- `zsh/config.zsh`
- `zsh/zenvs.zsh`
- `zsh/zaliases.zsh`
- `zsh/zfunctions.zsh`

## Implementation Steps

1. Add focused shell fixture tests for bootstrap managed blocks and all link-helper states.
2. Run `bash -n` for Bash entry points and `zsh -n` for zsh files; add ShellCheck where shell dialect/features permit.
3. Run macOS/Linux stubbed installer cases, including unsupported manager, missing network tool, privilege refusal, and missing zhist.
4. Smoke-test clean interactive shells: startup silence, history expansion, `Ctrl-R`, selected arrows, vi maps, autosuggestions, and failed-command display with zhist installed.
5. Execute the documented manual import in a disposable fixture; assert a second import is refused/skipped and legacy history remains.
6. Update operational docs and verify every command/path against the final scripts.

## Todo list

- [x] Create temporary-home fixture coverage.
- [x] Run syntax checks.
- [x] Run static analysis beyond syntax checks.
- [x] Validate macOS dry-run and unsupported-host paths.
- [ ] Validate Debian/Ubuntu APT paths.
- [ ] Validate a no-sudo Linux runtime.
- [ ] Perform manual interactive zhist smoke tests.
- [ ] Verify import idempotence and rollback.
- [x] Update and verify setup/migration documentation.

## Success Criteria

- All focused tests and syntax checks pass on supported platforms.
- No test case overwrites user configuration, replaces a foreign link, or creates root-owned home files.
- Documentation is sufficient to choose the supported install path, resolve expected conflicts, migrate history once, and restore native behavior.

## Risk Assessment

- Risk: CI cannot accurately emulate terminal key maps. Mitigation: require documented manual smoke tests on real macOS and Linux terminals.
- Risk: fixture stubs diverge from package managers. Mitigation: test dispatch/arguments in fixtures and perform one controlled real install per supported platform before release.

## Security Considerations

- Run all fixture tests in isolated temporary homes and remove only those known temporary directories after verification.
- Redact/avoid history entries and local environment data in test logs and documentation examples.

## Next steps

After validation passes, execute the rollout in the approved order: backup/check user state, bootstrap managed source block, configure links, provision selected dependencies, and perform optional one-time history import.
