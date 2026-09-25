# Next steps for another environment

## Cloud Agent environment and the devcontainer

Keep both. They are different machines.

| Path | Where it runs | What it is for |
|------|----------------|----------------|
| `.cursor/environment.json` and `.cursor/install.sh` | Cursor Cloud Agent, default image | Install the Ansible toolchain from `requirements.txt` and collections from `requirements.yml`. No Docker daemon. |
| `.devcontainer/` | Local VS Code or Codespaces, Ubuntu 26.04 | Docker-in-Docker so `molecule test` can start Ubuntu 26.04 and SLES 16 containers. |

Do not replace the Cloud Agent install script with the devcontainer image. Cloud Agents do not boot `.devcontainer`. Do not add a Docker daemon to `install.sh` just because Molecule exists. GitHub Actions and the devcontainer are the Molecule runners.

`install.sh` must keep installing `requirements.txt` and `requirements.yml` when those files exist. `requirements.yml` includes `community.docker` and `ansible.posix`. The Molecule Docker driver imports `community.docker.docker_login` and `ansible.posix.synchronize`. The default Cloud Agent image happened to have both collections already. GitHub-hosted runners do not.

Pull request 26 is merged. The environment on `main` still fits next to `.devcontainer/`: `install.sh` follows the requirements files and does not install a Docker daemon. Do not delete `.cursor/` because a devcontainer now exists.

This file is the handoff for a new Cloud Agent that has `CURSOR_UPDATE_ISSUE_TOKEN`.
Do not change code in `home-assistant`, `gpu-server`, `guardrails`, or `commondevops`.
Open GitHub issues only.

## Token

`CURSOR_REPO_READ_TOKEN` can read those private repos and gets HTTP 403 on the Issues API.
`CURSOR_UPDATE_ISSUE_TOKEN` was not injected into the agent that wrote this file.

Add it as a Runtime Secret named `CURSOR_UPDATE_ISSUE_TOKEN` under Cloud Agents → My Secrets,
applied to `pirlruc/ansible-roles` or to all repositories. Give it Issues: write on:

- `pirlruc/home-assistant`
- `pirlruc/gpu-server`
- `pirlruc/guardrails`
- `pirlruc/commondevops`

Secrets are injected when an agent starts. An agent that is already running will not see a secret
added later. Start a new agent, confirm `CURSOR_UPDATE_ISSUE_TOKEN` is set, and do not print it.

## Issues to open

### `pirlruc/home-assistant`

Title: Deprecate `ansible/roles/docker` in favor of `pirlruc/ansible-roles`

Body:

`ansible/roles/docker` installs Docker CE, the Compose plugin, starts systemd, and adds
`docker_user` to the `docker` group. `pirlruc/ansible-roles` now owns that split:

- role `docker` installs Engine and Compose on Ubuntu 26.04 and SLES 16. It probes
  `download.docker.com` for the apt suite and accepts `docker_apt_suite_override`.
- role `group_membership` adds an existing user to the existing `docker` group.

In `ansible/playbooks/site.yml`, replace `role: docker` with those two roles.
`docker_molecule_skip_daemon: true` becomes `docker_manage_service: false` and skipping
`group_membership`. Then delete `ansible/roles/docker`.

Do not move `host_base`, `host_updates`, `stack_layout`, `stack_backup`, `firewall`, or `network`.
There is no account, sudo, or general group role here to deprecate.

### `pirlruc/gpu-server`

Title: Use `pirlruc/ansible-roles` for the Ubuntu 26.04 Docker engine install only

Body:

`ubuntu_gpu_playbook/roles/docker_engine` duplicates the apt key, `docker-ce` packages, and
systemd start. Replace that install with role `docker` from `pirlruc/ansible-roles`.

Keep in this repo, after that role:

- `/etc/docker/daemon.json` from `nvidia_runtime_daemon_config` (`default-runtime: nvidia`) and its restart handler
- `nvidia_driver`, `nvidia_toolkit`, and `validation`

There is no user, sudo, or group role here. Nothing maps to `users`, `permissions`, or
`group_membership`.

Do not replace `sles_gpu_playbook/roles/docker_engine`. `sles_gpu_playbook/site.yml` asserts
SLES 15 and installs `docker` plus Package Hub `docker-compose` through `SUSEConnect`.
`pirlruc/ansible-roles` role `docker` accepts SLES 16 only and refuses SLES 15.
Leave the SLES role until that playbook moves to SLES 16.

### `pirlruc/guardrails`

Title: Add the `ansible/` pack vendored in `pirlruc/ansible-roles`

Body:

`guardrails` has no Ansible pack. `pirlruc/ansible-roles` vendors the proposed pack at
`docs/guardrails/ansible/` (`guardrails.md`, `profile.md`, `profile.thresholds.yml`).

IDs: `ANSIBLE-LANG-001`, `ANSIBLE-LANG-002`, `ANSIBLE-API-001`, `ANSIBLE-API-002`,
`ANSIBLE-LINT-001`, `ANSIBLE-LINT-002`, `ANSIBLE-TEST-001`, `ANSIBLE-TEST-002`,
`ANSIBLE-SEC-001`, `ANSIBLE-DOC-001`, `ANSIBLE-RUN-001`.

Thresholds: `ansible_core_min` `2.17`, `ansible_lint_profile` `production`,
`idempotence_runs` `2`, `supported_platforms` `ubuntu-26.04` and `sles-16`.

Copy those three files into `ansible/`, register `ANSIBLE` in `README.md`, and record the
decision in `docs/issues.yml` (epic id was drafted as `GR-PACK-006` in the vendor tree; pick
the next free `GR-PACK-*` id if `GR-PACK-006` is already taken). A contents write from the
previous agent returned HTTP 403.

Do not open a new methodologies or github-scaffold issue for this. Private-submodule pinning
is already `GR-DEP-PRIV`.

### `pirlruc/commondevops`

Title: Add `common-ansible-verify` for ansible-lint and Molecule

Body:

`pirlruc/ansible-roles` `.github/workflows/ci.yml` inlines:

- `pip install -r requirements.txt`
- `ansible-galaxy collection install -r requirements.yml`
- `python3 scripts/check-ansible-guardrails.py`
- `ansible-lint`
- `molecule test` for `ubuntu-accounts`, `sles-accounts`, `ubuntu-docker`, `sles-docker`

That body should become `.github/workflows/common-ansible-verify.yml` (`workflow_call`).
Inputs: scenario list, requirements files, `blocking`, `scripts_ref`. `scripts_ref` must
equal the caller's `uses:` pin (`CI-034`).

Do not fold ansible-lint's yamllint config into `common-doc-verify`. ansible-lint requires
its own YAML rules.

No new `containerdevops` workflow is required. After `COMMONDEVOPS_READ_TOKEN` and
`CONTAINERDEVOPS_READ_TOKEN` exist on `ansible-roles`, that repo should call the workflows
that already exist:

- `common-doc-verify` for YAML parse and link lint
- `common-infra-lint` for actionlint, ShellCheck, and zizmor
- `common-secrets-sast` for gitleaks
- `containerdevops` `container-devcontainer` for hadolint on `.devcontainer/Dockerfile`

Molecule Dockerfiles under `molecule/` are test images, not that devcontainer workflow's target.

## After the issues exist

Return to `pirlruc/ansible-roles` and point `.github/workflows/ci.yml` at
`common-ansible-verify` once that workflow is on `commondevops` `main`. Until then the
inline workflow stays.
