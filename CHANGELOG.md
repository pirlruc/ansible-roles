# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Role `git_core` installs the `git-core` package on Ubuntu 26.04 and SLES 16.
  The orchestrator runs it when `orchestrator_install_git` is true.

### Changed

- Pin SLES Molecule package installs to the SLE-BCI 16.0 versions for the
  current base digest and drop the hadolint DL3037 ignore.
- Call commondevops 5.1.2 `common-infra-lint`, `common-doc-verify`, and
  `common-secrets-sast`, and containerdevops 5.0.4 `container-devcontainer`.
  Pass `COMMONDEVOPS_READ_TOKEN` and `CONTAINERDEVOPS_READ_TOKEN` for the
  script checkout. Ansible lint, yamllint, and Molecule stay in this repo.
- Pin `docs/guardrails` to pirlruc/guardrails 1.8.0 and `.github/scaffold` to
  pirlruc/github-scaffold 1.7.0.
- Raise each role's `min_ansible_version` to 2.20, matching `ansible_core_min`.
- Lint playbooks under `molecule/` with ansible-lint. Keep `.github/` and `docs/`
  excluded, which is what ANSIBLE-LINT-003 allows.
- Group Dependabot updates into one monthly `all-dependencies` pull request
  covering GitHub Actions, pip, git submodules, and Dockerfiles.
