# ansible-roles

Independent Ansible roles for Docker Engine, local accounts, filesystem and sudo permissions, and membership in groups that already exist. An orchestrator playbook orders them. Nothing in one role calls another.

Platforms: Ubuntu 26.04 and SLES 16.

## Roles

| Role | Does | Does not |
|------|------|----------|
| `users` | Create or remove local accounts | Set supplementary groups, sudo, or file modes |
| `permissions` | Set path mode/owner and `/etc/sudoers.d` drop-ins | Create accounts |
| `group_membership` | Add or remove users on an existing group | Create the group or the user |
| `docker` | Install Docker Engine and Compose v2 | Create users or add them to the `docker` group |

`playbooks/orchestrate.yml` runs account, permissions, and group membership, then Docker, then a second `group_membership` pass so users can join the `docker` group the package creates.

## Guardrails

Ansible thresholds live at `docs/guardrails/ansible/` (`ANSIBLE-*`, epic GR-PACK-006). CI reads `profile.thresholds.yml` and fails closed when a key is missing. `docs/guardrail-deviations.yml` is empty. The same pack was prepared for [pirlruc/guardrails](https://github.com/pirlruc/guardrails); this environment could not push there.

`pirlruc/home-assistant` and `pirlruc/gpu-server` are not visible with the credentials available to this repository, so those trees were not used as role examples.

## Local test

Two environments stay side by side. `.cursor/install.sh` installs the Ansible toolchain from `requirements.txt` and `requirements.yml` on the Cursor Cloud Agent image. It does not install a Docker daemon. `.devcontainer/` is Ubuntu 26.04 with Docker-in-Docker so local Molecule can start Ubuntu 26.04 and SLES 16 containers. GitHub Actions and the devcontainer run Molecule. Cloud Agents do not boot `.devcontainer`.

Supported platforms are Ubuntu 26.04 and SLES 16.

```sh
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
python3 scripts/check-ansible-guardrails.py
yamllint .
ansible-lint
ansible-playbook --syntax-check playbooks/orchestrate.yml
molecule test -s ubuntu-accounts
molecule test -s sles-accounts
```

Docker install scenarios (`ubuntu-docker`, `sles-docker`) pull upstream packages and need network.

## Example

```sh
ansible-playbook -i inventory playbooks/orchestrate.yml -e @examples/host-vars.yml
```

`examples/host-vars.yml` assumes the `operators` group already exists. Create that group outside these roles.
