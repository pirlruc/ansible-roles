# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-11-15

### Added

- `docker_daemon` refuses any host that is not Ubuntu 26.04 or SLES 16.
  Molecule covers the merge on both, including a key the fragment does not mention.
- `release.yml` publishes a GitHub Release from an annotated `1.*` tag.
- Callers pin commondevops `v6.5.0`.

### Fixed

- The thresholds job pins `ubuntu-24.04`.
- Dependabot's docker update no longer sends the git registry token to registry.suse.com.

## [1.0.0] - 2026-11-15

### Added

- Role `git_core` installs the `git-core` package on Ubuntu 26.04 and SLES 16.
  The orchestrator runs it when `orchestrator_install_git` is true.

### Changed

- Pin `docs/guardrails` to 1.15.0 and `.github/scaffold` to 1.12.0.
- Call commondevops 6.5.0 and containerdevops 6.5.0. Molecule, yamllint, and
  ansible-lint run through `common-ansible-verify`. Requirements are hash-locked.
- Dependabot gives each ecosystem a 7-day cooldown and groups the updates.
- SLES Molecule package installs stay pinned to the SLE-BCI 16.0 versions for
  the current base digest.
