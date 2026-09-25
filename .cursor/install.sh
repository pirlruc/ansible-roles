#!/usr/bin/env bash
# Cloud Agent toolchain on Cursor's default image.
#
# Molecule against Ubuntu 26.04 and SLES 16 runs in .devcontainer/ (Docker-in-Docker)
# and in GitHub Actions. This script does not install a Docker daemon.
# When requirements.txt and requirements.yml exist, they are the version source.
# The pinned fallback below is only for a checkout that does not have them yet.
set -euo pipefail

VENV="${ANSIBLE_VENV:-$HOME/.venv/ansible}"

if ! python3 -c 'import ensurepip' >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3.12-venv
fi

if [ ! -x "$VENV/bin/python" ]; then
  python3 -m venv "$VENV"
fi

"$VENV/bin/pip" install --quiet --upgrade pip wheel

if [ -f requirements.txt ]; then
  "$VENV/bin/pip" install --quiet -r requirements.txt
else
  "$VENV/bin/pip" install --quiet \
    "ansible-core==2.21.4" \
    "ansible-lint==26.9.0" \
    "yamllint==1.38.0" \
    "molecule==26.9.0"
fi

if [ -f requirements.yml ]; then
  "$VENV/bin/ansible-galaxy" collection install -r requirements.yml
fi

for tool in "$VENV"/bin/ansible "$VENV"/bin/ansible-* \
  "$VENV"/bin/ansible-lint "$VENV"/bin/yamllint "$VENV"/bin/molecule; do
  [ -e "$tool" ] && sudo ln -sf "$tool" /usr/local/bin/
done

echo "Ansible toolchain ready:"
"$VENV/bin/ansible" --version | head -1
"$VENV/bin/ansible-lint" --version | head -1
"$VENV/bin/yamllint" --version
"$VENV/bin/molecule" --version | head -1
