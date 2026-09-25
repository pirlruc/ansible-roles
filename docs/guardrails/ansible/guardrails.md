# Ansible Guardrails (Generic)

Repository-agnostic principles for Ansible roles and the playbooks that compose them.
Org defaults: [`profile.md`](profile.md).

Cross-language CI mechanics live in [`../ci/guardrails.md`](../ci/guardrails.md). Do not restate
`CI-*` rules here. Cite `CI-008` for local parity, `CI-009` for lint, `CI-010` for tests, and
`CI-022` for reading this pack's thresholds.

## Language & toolchain

- **[ANSIBLE-LANG-001]** Tasks, handlers, and plays use fully qualified collection names (`ansible.builtin.*` and other FQCNs). Short module names are not allowed.
- **[ANSIBLE-LANG-002]** Require `ansible-core` at or above `ansible_core_min` (see `profile.thresholds.yml`).

## Role boundaries

- **[ANSIBLE-API-001]** A role does one thing and lists `dependencies: []` unless it cannot succeed without another role. Composition of independent roles belongs to an orchestrator playbook, not to hidden `import_role` chains.
- **[ANSIBLE-API-002]** Every role publishes `meta/argument_specs.yml` for the inputs it accepts. Callers pass data; roles do not reach into another role's defaults.

## Lint

- **[ANSIBLE-LINT-001]** `ansible-lint` runs at `ansible_lint_profile` and fails the gate. Profile `min` or `basic` is below the org default.
- **[ANSIBLE-LINT-002]** YAML committed for playbooks, roles, and molecule scenarios passes `yamllint`.

## Testing

- **[ANSIBLE-TEST-001]** Each supported platform in `supported_platforms` has an automated scenario (Molecule or equivalent) for every role that changes that platform.
- **[ANSIBLE-TEST-002]** Scenarios run at least `idempotence_runs` converges. The second converge reports no changes.

## Security

- **[ANSIBLE-SEC-001]** Account secrets are password hashes or runtime lookups. Plaintext passwords are not role defaults, task args, or logged output.

## Documentation

- **[ANSIBLE-DOC-001]** Each role has a README naming platforms, variables, dependencies (or the absence of them), and a minimal example.

## Runtime platforms

- **[ANSIBLE-RUN-001]** The repository declares the platforms in `supported_platforms` and does not claim a platform it does not test.

## Thresholds

Every key in [`profile.thresholds.yml`](profile.thresholds.yml) is listed here.

| Key | Org default | Guardrail |
|-----|-------------|-----------|
| `ansible_core_min` | `2.17` | ANSIBLE-LANG-002 |
| `ansible_lint_profile` | `production` | ANSIBLE-LINT-001 |
| `idempotence_runs` | `2` | ANSIBLE-TEST-002 |
| `supported_platforms` | `ubuntu-26.04`, `sles-16` | ANSIBLE-RUN-001, ANSIBLE-TEST-001 |

## References

- [Ansible role argument specs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#role-argument-validation)
- [ansible-lint profiles](https://ansible.readthedocs.io/projects/lint/profiles/)
- [Molecule](https://ansible.readthedocs.io/projects/molecule/)
