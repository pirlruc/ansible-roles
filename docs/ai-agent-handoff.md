# AI agent handoff — ansible-roles

*Last updated: 2026-11-15 — docker_daemon asserts Ubuntu 26.04 and SLES 16 and has its own Molecule scenarios. release.yml calls common-release. Dependabot docker no longer attaches the git registry. 1.1.0 is not tagged.*

## Identity

| Field | Value |
|-------|-------|
| Remote | https://github.com/pirlruc/ansible-roles (public) |
| Guardrails | submodule `docs/guardrails` tag **1.15.0** → `2d4bb70e95449f6922781716857adeb22badf676` |
| Scaffold | submodule `.github/scaffold` tag **1.12.0** → `9c443ea978851768f451b1df2020dd86dfb1a967` |
| commondevops pin | tag **v6.5.0** → `ee91ea75b6f60bc55ec5a95e1692865ee96485e9` |
| containerdevops pin | tag **6.5.0** → `b8c0746603eefdc89571b17c62d1e965b28ff31f` |

## Delivery status

| Epic | Status |
|------|--------|
| AR-ROLE-001 | Done |
| AR-PIN-001 | Done. Synced |
| AR-ROLE-002 | Done in the manifest. Sync after the pull request merges. |
| AR-CI-001 | Done. Synced |
| AR-ROLE-003 | Done. Role `git_core` |
| AR-CI-002 | Done. Public `workflow_call` plus a token-free Ansible job |

`docs/guardrail-deviations.yml` is empty.

## Commands

```sh
git submodule update --init --recursive
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
sh scripts/check-submodule-pins.sh
sh scripts/install-lint-tools.sh
export PATH="${HOME}/.local/bin:${PATH}"
shellcheck .cursor/install.sh scripts/*.sh
actionlint
python3 scripts/lint-doc-links.py
python3 scripts/check-ansible-guardrails.py
sh scripts/check-lint-thresholds.sh
yamllint .
ansible-lint
ansible-playbook --syntax-check playbooks/orchestrate.yml
molecule test -s ubuntu-docker-daemon
molecule test -s sles-docker-daemon
```

`scripts/lint-doc-links.py` is vendored from methodologies **1.7.0**
`common/scripts/lint-doc-links.py`. Issue sync validate (no writes):

```sh
python3 .github/scaffold/scripts/issues-sync.py --yaml docs/issues.yml --validate-only
```

## Known pitfalls

- **Private submodules.** `GITHUB_TOKEN` cannot clone `docs/guardrails`. The
  thresholds job needs Actions secret `GUARDRAILS_READ_TOKEN` (contents read on
  `pirlruc/guardrails`). Dependabot skips that job (CI-024).
  `common-ansible-verify` passes an empty `check_script` so it does not run
  the reader that needs the submodule.
- **Private CI images.** This repo has no `GHCR_READ_TOKEN`. infra-lint,
  secrets-sast, and supply-chain pass public
  `ghcr.io/catthehacker/ubuntu:act-24.04` with `mount_runner_git: false`.
  The called workflow still logs in with `github.token`, which can pull that
  public image. Do not switch those jobs to `ghcr.io/pirlruc/ci-lint` without
  a packages read token. Fold the digest onto the next line. Yamllint's
  120-character limit rejects it on one line.
- **Hashed requirements.** `requirements.txt` is a uv lock with `--hash`
  lines so `common-ansible-verify` can use `--require-hashes` (CI-039).
  Direct pins live in `requirements.in`. Recompile with
  `uv pip compile requirements.in --python 3.13 --generate-hashes --universal -o requirements.txt`.
- **Dependabot git submodules.** `.github/dependabot.yml` attaches registry
  `github-private` to the `gitsubmodule` and `github-actions` ecosystems.
  The docker ecosystem does not attach it. That git token made
  registry.suse.com fail as a private source. Dependabot reads
  `DEPENDABOT_GITHUB_TOKEN` from the Dependabot secret store only. An Actions
  workflow cannot see that store, even when the names match.
- **SLES hadolint.** Molecule Dockerfiles pin `python3`, `shadow`, and `sudo`
  to the SLE-BCI 16.0 x86_64 product repo versions for base digest
  `sha256:60c29bd0b778`. Refresh those pins when the base digest changes.
- **Molecule.** Needs a Docker daemon. `.cursor/install.sh` does not install one.
  Cloud Agents run the lint gates, not Molecule.
- **Global git insteadOf.** This environment rewrites `https://github.com/` to
  the app token, which cannot read the private submodules. `ci-init-guardrails.sh`
  sets a longer `insteadOf` for the guardrails URL only.

## Suggested next work

1. Add `GUARDRAILS_READ_TOKEN` on this repository if the thresholds job is red.
2. Confirm the next docker Dependabot update no longer reports
   `private_source_authentication_failure` for `registry.suse.com`.
3. Tag `1.1.0` after this pull request merges. `release.yml` pins
   commondevops `v6.5.0` (`ee91ea75`). A GitHub Release was not created for
   that tag, so the CI images were not republished.
4. Galaxy metadata stays `all` because ansible-lint `schema[meta]` has no
   Ubuntu 26.04 entry. The tasks assert the release.
   Pin bumps filed as
   [commondevops#158](https://github.com/pirlruc/commondevops/issues/158)
   and [containerdevops#122](https://github.com/pirlruc/containerdevops/issues/122).
   Fixture hadolint:
   [containerdevops#123](https://github.com/pirlruc/containerdevops/issues/123).
   Token-free link lint:
   [github-scaffold#146](https://github.com/pirlruc/github-scaffold/issues/146).
   Docker-pack scope:
   [guardrails#181](https://github.com/pirlruc/guardrails/issues/181).

## Recent history

- 2026-11-15: Fold the public CI image digest so yamllint's 120-character
  limit passes. Call commondevops and containerdevops 6.5.0. Molecule, yamllint,
  and ansible-lint go through `common-ansible-verify`. `token-probe.yml` is
  replaced by `common-token-audit`. Requirements are hash-locked.
- 2026-09-29: Call public commondevops 5.1.2 and containerdevops 5.0.4
  workflows with the read tokens. Pin SLES zypper package versions. Add
  role `git_core`.
- 2026-09-29: Pin guardrails 1.8.0 and github-scaffold 1.7.0 as submodules.
  Ansible floor 2.20. Molecule playbooks are in the ansible-lint scope.
  Companion issues: commondevops#157, commondevops#158, containerdevops#122,
  containerdevops#123, github-scaffold#146, guardrails#181.
