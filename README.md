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

[pirlruc/guardrails](https://github.com/pirlruc/guardrails) tag **1.8.0** (`aa5184ceaa5d005a71d984fd771564cb10b63681`) is the `docs/guardrails` submodule. [pirlruc/github-scaffold](https://github.com/pirlruc/github-scaffold) tag **1.7.0** (`e76bb3fda306c490b4b3ea5e1a4e3977e04a1a1d`) is the `.github/scaffold` submodule. CI reads `docs/guardrails/ansible/profile.thresholds.yml` and fails closed when a key is missing. `docs/guardrail-deviations.yml` is empty.

```sh
git submodule update --init --recursive
```

A public checkout cannot fetch those private submodules without a token that has contents read on both repositories. GitHub Actions uses the `GUARDRAILS_READ_TOKEN` secret for `docs/guardrails`.

## Local test

Two environments stay side by side. `.cursor/install.sh` installs the Ansible toolchain from `requirements.txt` and `requirements.yml` on the Cursor Cloud Agent image. It does not install a Docker daemon. `.devcontainer/` is Ubuntu 26.04 with Docker-in-Docker so local Molecule can start Ubuntu 26.04 and SLES 16 containers. GitHub Actions and the devcontainer run Molecule. Cloud Agents do not boot `.devcontainer`.

Supported platforms are Ubuntu 26.04 and SLES 16.

```sh
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
sh scripts/check-submodule-pins.sh
sh scripts/install-lint-tools.sh
shellcheck .cursor/install.sh scripts/*.sh
actionlint
python3 scripts/lint-doc-links.py
python3 scripts/check-ansible-guardrails.py
sh scripts/check-lint-thresholds.sh
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
