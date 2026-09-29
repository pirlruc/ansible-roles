# AI agent handoff — ansible-roles

*Last updated: 2026-09-29*

## Identity

| Field | Value |
|-------|-------|
| Remote | https://github.com/pirlruc/ansible-roles (public) |
| Guardrails | submodule `docs/guardrails` tag **1.8.0** → `aa5184ceaa5d005a71d984fd771564cb10b63681` |
| Scaffold | submodule `.github/scaffold` tag **1.7.0** → `e76bb3fda306c490b4b3ea5e1a4e3977e04a1a1d` |
| commondevops pin (tools only) | tag **5.1.2** → `b3c462bed0de4f6475e6be7875c4ababd831acc6` |
| containerdevops pin (not called) | tag **5.0.4** → `2dd60d34418051fb0505f476d926b20550becfad` |

## Delivery status

| Epic | Status |
|------|--------|
| AR-ROLE-001 | Done |
| AR-PIN-001 | Done in tree. Not synced to GitHub issues |
| AR-ROLE-002 | Open (`docker_daemon`) |
| AR-CI-001 | Open. Do not edit its GitHub issue |
| AR-CI-002 | Open. Inline gates stay until a public `workflow_call` path exists |

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
```

`scripts/lint-doc-links.py` is vendored from methodologies **1.7.0**
`common/scripts/lint-doc-links.py`. Issue sync validate (no writes):

```sh
python3 .github/scaffold/scripts/issues-sync.py --yaml docs/issues.yml --validate-only
```

## Known pitfalls

- **Private submodules.** `GITHUB_TOKEN` cannot clone `docs/guardrails`. The
  thresholds job needs Actions secret `GUARDRAILS_READ_TOKEN` (contents read on
  `pirlruc/guardrails`). Dependabot skips that job (CI-024). The lint job does
  not need the secret.
- **Private workflow_call.** This repo is public and the owner is a user account.
  `uses:` of `pirlruc/commondevops` or `pirlruc/containerdevops` does not resolve.
  Do not add those calls until a public pull request proves they load.
- **Dependabot git submodules.** `.github/dependabot.yml` attaches registry
  `github-private` to the `gitsubmodule` ecosystem. That stays red until
  Dependabot secret `DEPENDABOT_GITHUB_TOKEN` exists (not an Actions secret).
  Close the old per-ecosystem Dependabot PR after this config is on `main`, or
  the open-PR limit blocks the grouped `all-dependencies` PR.
- **SLES hadolint.** `molecule/sles-*/Dockerfile` ignore DL3037. The BCI
  repository has no public package lockfile. Ubuntu lines pin versions.
- **Molecule.** Needs a Docker daemon. `.cursor/install.sh` does not install one.
  Cloud Agents run the lint gates, not Molecule.
- **Global git insteadOf.** This environment rewrites `https://github.com/` to
  the app token, which cannot read the private submodules. `ci-init-guardrails.sh`
  sets a longer `insteadOf` for the guardrails URL only.

## Suggested next work

1. Add `GUARDRAILS_READ_TOKEN` on this repository if the thresholds job is red.
2. Add Dependabot secret `DEPENDABOT_GITHUB_TOKEN`, then confirm one
   `all-dependencies` PR.
3. `docker_daemon` (AR-ROLE-002).
4. Switch inline gates to reusable workflows only after
   [commondevops#157](https://github.com/pirlruc/commondevops/issues/157)
   (public caller) and [commondevops#152](https://github.com/pirlruc/commondevops/issues/152)
   (`common-ansible-verify`) land.
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

- 2026-09-29: Pin guardrails 1.8.0 and github-scaffold 1.7.0 as submodules.
  Ansible floor 2.20. Molecule playbooks are in the ansible-lint scope.
  Companion issues: commondevops#157, commondevops#158, containerdevops#122,
  containerdevops#123, github-scaffold#146, guardrails#181.
