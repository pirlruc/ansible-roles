# AI agent handoff — ansible-roles

*Last updated: 2026-11-24 — MIT LICENSE and SECURITY.md are in the tree. Local pip install uses --require-hashes. Pins are guardrails 1.17.1, scaffold 1.14.3, commondevops v6.12.0, and containerdevops 6.10.0. CodeQL calls common-codeql for the actions language. Dependabot docker still fails on registry.suse.com; the docker entry does not attach a registry.*

## Identity

| Field | Value |
|-------|-------|
| Remote | https://github.com/pirlruc/ansible-roles (public) |
| Guardrails | submodule `docs/guardrails` tag **1.17.1** → `8508e93691aa3c4f769ecc215ddc83ecf26e70b2` |
| Scaffold | submodule `.github/scaffold` tag **1.14.3** → `1fca8a3b79c10d38d5b39747d2363070a07503da` |
| commondevops pin | tag **v6.12.0** → `ff65e7efbb7eea67bd659f886db0adb399f3a3f5` |
| containerdevops pin | tag **6.10.0** → `b1cf0dead2b1a501bf1433fe72cdbbdad4e9132d` |

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
pip install --require-hashes -r requirements.txt
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
- **Hashed requirements.** `requirements.txt` already has `--hash` lines.
  `common-ansible-verify` and `scripts/check-ci-local.sh` both pass
  `--require-hashes` (CI-039). Direct pins live in `requirements.in`.
  Recompile with
  `uv pip compile requirements.in --python 3.13 --generate-hashes --universal -o requirements.txt`.
- **LICENSE and SECURITY.md.** Root `LICENSE` is MIT. Galaxy role meta names
  author `pirlruc` and license MIT, and does not name a copyright holder, so
  the notice is "The ansible-roles authors". `SECURITY.md` points at
  https://github.com/pirlruc/ansible-roles/security/advisories/new and says
  not to open a public issue for a secret. Private vulnerability reporting
  is still `enabled: false` (`GET /repos/pirlruc/ansible-roles/private-vulnerability-reporting`).
  Turning it on is repository administration and was not done here, so that
  URL does not accept reports until a maintainer enables it (DOC-PUB-002).
- **Dependabot docker.** The docker `updates` entry does not set `registries`.
  `github-private` stays on `github-actions` and `gitsubmodule` only.
  Run `43750652078` (2026-11-15, update job `1705989109`) still failed.
  The docker job is `multi-ecosystem-update: true` and its
  `credentials-metadata` is `git_source` for `github.com`, inherited from
  the grouped `github-actions` entry. The proxy then logged
  `egress not allowlisted registry.suse.com` and
  `private_source_authentication_failure` for `bci/bci-base` (three SLES
  directories). Ubuntu tags needed no update. No config edit: the directories
  are the Dockerfiles that exist, and attaching a registry to docker would
  send the git token at registry.suse.com again. Removing `github-private`
  from `github-actions` would drop private git access.
  Dependabot reads `DEPENDABOT_GITHUB_TOKEN` from the Dependabot secret
  store only. An Actions workflow cannot see that store.
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
2. Dependabot docker still reports `private_source_authentication_failure`
   for `registry.suse.com` (run `43750652078`). The docker entry does not
   attach `registries`. The grouped job still carries the git credential.
   Do not attach `github-private` to docker.
3. Tag `1.1.0` exists on the remote (`5e0263eb`) and the GitHub Release
   `1.1.0` was published 2026-11-15. Do not create that tag again.
   `1.1.1` is the changelog heading for the license, hashed pip install,
   and actions CodeQL. Cut the annotated tag only after that heading is
   on `main`. `release.yml` pins commondevops `v6.12.0` (`ff65e7ef`).
4. Enable private vulnerability reporting so the `SECURITY.md` URL accepts
   reports. That is a repository setting.
5. Galaxy metadata stays `all` because ansible-lint `schema[meta]` has no
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

- 2026-11-25: Close changelog `1.1.1` for the license, hashed pip install,
  and the actions CodeQL workflow. The annotated tag follows the merge.
- 2026-11-24: Root MIT `LICENSE` and `SECURITY.md`. Local pip install passes
  `--require-hashes` against the existing hashed `requirements.txt`. Pins
  are guardrails 1.17.1 and github-scaffold 1.14.3. `codeql.yml` calls
  `common-codeql` at commondevops v6.12.0 for the actions language.
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
