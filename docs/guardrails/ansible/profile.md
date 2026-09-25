# Ansible Org Profile (Central Defaults)

Numeric gates: [`profile.thresholds.yml`](profile.thresholds.yml). Principles: [`guardrails.md`](guardrails.md).

## Fixed baseline

| Area | Value | Guardrail |
|------|-------|-----------|
| ansible-core | >= `ansible_core_min` (`2.17`) | ANSIBLE-LANG-002 |
| Module names | FQCN only | ANSIBLE-LANG-001 |
| Role composition | Orchestrator playbook; empty role dependencies unless a role cannot run alone | ANSIBLE-API-001 |
| Platforms | `supported_platforms` | ANSIBLE-RUN-001 |

## Predetermined tools (recommended)

| Category | Org default | Guardrail |
|----------|-------------|-----------|
| Role lint | `ansible-lint` at `ansible_lint_profile` | ANSIBLE-LINT-001 |
| YAML lint | `yamllint` | ANSIBLE-LINT-002 |
| Scenario tests | Molecule (or equivalent) per `supported_platforms` entry | ANSIBLE-TEST-001 |
| Idempotence | `idempotence_runs` converges | ANSIBLE-TEST-002 |
| Role contract | `meta/argument_specs.yml` | ANSIBLE-API-002 |
| Role docs | Role `README.md` | ANSIBLE-DOC-001 |

## Numeric gates

| Category | Org default | Guardrail |
|----------|-------------|-----------|
| ansible-core floor | `ansible_core_min` | ANSIBLE-LANG-002 |
| ansible-lint profile | `ansible_lint_profile` | ANSIBLE-LINT-001 |
| Idempotent converges | `idempotence_runs` | ANSIBLE-TEST-002 |
| Platform matrix | `supported_platforms` | ANSIBLE-RUN-001 |

## Deviation rule

See [`../README.md`](../README.md). Skipping a platform, lowering the lint profile, or accepting a single converge requires an Epic (or ADR). Cite `ANSIBLE-LINT-001`, `ANSIBLE-TEST-001`, or `ANSIBLE-TEST-002`.
