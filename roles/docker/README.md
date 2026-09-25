# docker

Installs Docker Engine and Compose v2.

- Ubuntu 26.04 (resolute): Docker's apt repository and `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`.
- SLES 16: openSUSE `Virtualization:containers` 16.0 packages `docker`, `docker-compose`, and `docker-buildx`. SUSE's default container tool is Podman; this role installs Docker Engine on purpose.

The role does not create users and does not add anyone to the `docker` group. The engine package creates that group. `playbooks/orchestrate.yml` can call `group_membership` afterwards.

Set `docker_use_transactional_update: true` on transactional SLES so packages land in a new snapshot. The service starts on the next boot in that mode.

## Dependencies

None. SLES package installs use `community.general.zypper` from `requirements.yml`. Ubuntu uses `ansible.builtin.apt`.

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `docker_manage_service` | `true` | Start and enable `docker` when `/run/systemd/system` exists. |
| `docker_verify_cli` | `true` | Run `docker compose version` after install. |
| `docker_use_transactional_update` | `false` | Use `transactional-update pkg install` on SLES. |
| `docker_suse_baseurl` | OBS 16.0 URL | SLES repository base. |
| `docker_suse_gpgkey` | OBS 16.0 key | SLES repository key. |

## Example

```yaml
- name: Install Docker
  hosts: servers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: docker
```
