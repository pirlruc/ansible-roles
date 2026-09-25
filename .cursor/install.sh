#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the ansible-roles repository.
# Provisions a self-contained Ansible role development toolchain
# (ansible-core, ansible-lint, yamllint, molecule) in a dedicated
# virtualenv and exposes it on PATH via /usr/local/bin.
set -euo pipefail

VENV="${ANSIBLE_VENV:-$HOME/.venv/ansible}"

# ansible-core / ansible-lint / yamllint / molecule are pinned for
# reproducible snapshots. Bump deliberately, not incidentally.
ANSIBLE_CORE_VERSION="2.21.4"
ANSIBLE_LINT_VERSION="26.9.0"
YAMLLINT_VERSION="1.38.0"
MOLECULE_VERSION="26.9.0"

# The default base image ships Python 3.12 but not the venv module.
if ! python3 -c 'import ensurepip' >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3.12-venv
fi

if [ ! -x "$VENV/bin/python" ]; then
  python3 -m venv "$VENV"
fi

"$VENV/bin/pip" install --quiet --upgrade pip wheel
"$VENV/bin/pip" install --quiet \
  "ansible-core==${ANSIBLE_CORE_VERSION}" \
  "ansible-lint==${ANSIBLE_LINT_VERSION}" \
  "yamllint==${YAMLLINT_VERSION}" \
  "molecule==${MOLECULE_VERSION}"

# Optional project-managed dependencies (present once roles are added).
if [ -f requirements.txt ]; then
  "$VENV/bin/pip" install --quiet -r requirements.txt
fi
if [ -f requirements.yml ]; then
  "$VENV/bin/ansible-galaxy" install -r requirements.yml
fi

# Expose the toolchain on PATH deterministically, independent of
# login-shell profile timing.
for tool in "$VENV"/bin/ansible "$VENV"/bin/ansible-* \
  "$VENV"/bin/ansible-lint "$VENV"/bin/yamllint "$VENV"/bin/molecule; do
  [ -e "$tool" ] && sudo ln -sf "$tool" /usr/local/bin/
done

echo "Ansible toolchain ready:"
"$VENV/bin/ansible" --version | head -1
"$VENV/bin/ansible-lint" --version | head -1
"$VENV/bin/yamllint" --version
"$VENV/bin/molecule" --version | head -1
