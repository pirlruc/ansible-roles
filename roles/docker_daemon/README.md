# docker_daemon

Merges a hardened `/etc/docker/daemon.json` into a host that already runs Docker Engine. ANSIBLE-SEC-004.

The merge keeps keys that are already in the file. It does not add a TCP listener. `live-restore`, `no-new-privileges`, and json-file log rotation are set.

Galaxy `platforms.versions` stays `all` because ansible-lint `schema[meta]` has no Ubuntu 26.04 entry. The tasks assert Ubuntu 26.04 or SLES 16 and refuse every other distribution. The role does not install packages.

## Dependencies

None. `meta/main.yml` sets `dependencies: []`. The `docker` role includes this role after the packages are installed.

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `docker_daemon_manage_service` | `true` | Restart Docker when the file changes. Set false when Docker is not installed. |
| `docker_daemon_required` | live-restore, no-new-privileges, json-file logs | Keys merged into `daemon.json`. |

## Example

```yaml
- name: Harden the Docker daemon
  hosts: servers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: docker_daemon
```
