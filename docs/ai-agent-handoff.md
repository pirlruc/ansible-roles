# AI Agent Handoff Log

**Last updated:** 2026-09-25
**Last agent focus:** Docker, account, permissions, and group-membership roles

## What landed

- Roles `docker`, `users`, `permissions`, and `group_membership` with empty `dependencies`.
- Ubuntu Docker install probes `download.docker.com` for the apt suite (`docker_apt_suite_override`), taken from home-assistant's docker role.
- `playbooks/orchestrate.yml` is the only composition point. It runs `group_membership` again after `docker` so the `docker` group exists first.
- Molecule scenarios `ubuntu-accounts`, `sles-accounts`, `ubuntu-docker`, `sles-docker`.
- Vendored Ansible guardrail pack at `docs/guardrails/ansible/` (org pack authored in `pirlruc/guardrails` as GR-PACK-006).
- Devcontainer (Ubuntu 26.04) plus Dockerfile for local Molecule.

## Reference repos

- `pirlruc/methodologies` github-issue-adr: pin guardrails, do not hide role dependencies, record deviations in `docs/guardrail-deviations.yml`.
- `pirlruc/guardrails` had no Ansible pack. GR-PACK-006 adds `ansible/`.
- `pirlruc/home-assistant` and `pirlruc/gpu-server` returned 404. No Ansible roles were found under `pirlruc/commondevops`, `containerdevops`, or `infrastructure`.

## Follow-ups

- Land `docs/guardrails/ansible/` on `pirlruc/guardrails` as [GR-PACK-006](https://github.com/pirlruc/guardrails/issues/172). The pack is vendored here against guardrails main `1a0dab01cf342dabfe7319ccefacb44a82cfb795` because a contents write returned HTTP 403. The issue is open; do not push the pack from this repo.
- Full `docs/guardrails` submodule is not used: guardrails is private and this repo is public. Only the Ansible pack is vendored (CI-021).
- SLES Docker uses the openSUSE Virtualization:containers 16.0 repository because SLES 16 defaults to Podman. SLES 15 is not a supported platform. gpu-server tracks the playbook move in [GPU-SLES-001](https://github.com/pirlruc/gpu-server/issues/13).
