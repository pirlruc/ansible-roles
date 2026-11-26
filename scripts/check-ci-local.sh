#!/usr/bin/env bash
# Host-first parity for the lint job. Molecule stays in Docker.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if [[ ! -d .venv ]]; then
  python3 -m venv .venv
  .venv/bin/pip install --require-hashes -r requirements.txt
fi
.venv/bin/ansible-galaxy collection install -r requirements.yml
sh scripts/check-submodule-pins.sh
sh scripts/check-threshold-drift.sh
.venv/bin/yamllint .
.venv/bin/ansible-lint
.venv/bin/ansible-playbook --syntax-check playbooks/orchestrate.yml
bash -n scripts/check-ci-local.sh
