# users

Creates or removes local accounts. A private primary group is created with the account by the platform user tools. This role does not set supplementary groups, sudo, or file modes.

## Platforms

Ubuntu 26.04 and SLES 16.

## Dependencies

None. `meta/main.yml` sets `dependencies: []`.

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `users_accounts` | `[]` | List of accounts. See `meta/argument_specs.yml`. |

`password`, when set, must be a hash (`$6$...`, `$y$...`). Plaintext fails the role.

## Example

```yaml
- name: Create operators
  hosts: servers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: users
      vars:
        users_accounts:
          - name: alice
            comment: Alice
            shell: /bin/bash
```

Group membership and permissions stay in their own roles. `playbooks/orchestrate.yml` orders them.
