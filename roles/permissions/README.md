# permissions

Sets ownership, mode, and sudoers drop-ins. It does not create users or groups. Create the account with `users` first when `owner` or a sudoers user must exist. `playbooks/orchestrate.yml` does that ordering.

## Platforms

Ubuntu 26.04 and SLES 16. `visudo` must be installed (sudo package).

## Dependencies

None.

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `permissions_paths` | `[]` | `ansible.builtin.file` entries (`path`, `state`, `mode`, `owner`, `group`). |
| `permissions_sudoers` | `[]` | Drop-ins in `/etc/sudoers.d`, checked with `visudo -cf`. |

## Example

```yaml
permissions_paths:
  - path: /var/lib/app
    state: directory
    mode: "0750"
    owner: alice
    group: alice
permissions_sudoers:
  - name: alice-restart
    user: alice
    commands:
      - /usr/bin/systemctl restart app
    nopasswd: false
```
