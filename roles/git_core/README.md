# git_core

Installs the `git-core` package. This role does not configure remotes, credentials, or user identity.

## Platforms

Ubuntu 26.04 and SLES 16.

On Ubuntu 26.04, `git-core` is a virtual package provided by `git`. Apt installs that provider. On SLES 16, `git-core` is the real package.

## Dependencies

None. `meta/main.yml` sets `dependencies: []`.

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `git_core_package` | `git-core` | Package name passed to apt or zypper. |

## Example

```yaml
- name: Install git
  hosts: servers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: git_core
```

`playbooks/orchestrate.yml` imports this role when `orchestrator_install_git` is true.
