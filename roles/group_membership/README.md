# group_membership

Adds or removes users on a group that already exists. Missing groups or users fail the role. This role does not create either.

The Docker engine creates the `docker` group when it is installed. Add people to that group from the orchestrator after the `docker` role, not from inside it.

## Platforms

Ubuntu 26.04 and SLES 16.

## Dependencies

None.

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `group_membership_entries` | `[]` | Each item has `group`, `members`, and optional `state` (`present` or `absent`). |

## Example

```yaml
- name: Join an existing operators group
  hosts: servers
  become: true
  tasks:
    - ansible.builtin.import_role:
        name: group_membership
      vars:
        group_membership_entries:
          - group: operators
            members:
              - alice
```
