#!/bin/sh
# Read shell and docker numeric gates from the pinned guardrails checkout.
# Missing file or empty key fails closed (CI-022).
set -eu

ROOT="$(git rev-parse --show-toplevel)"
cd "${ROOT}"

SHELL_FILE="docs/guardrails/shell/profile.thresholds.yml"
DOCKER_FILE="docs/guardrails/docker/profile.thresholds.yml"

if [ ! -f "${SHELL_FILE}" ] || [ ! -f "${DOCKER_FILE}" ]; then
  echo "guardrails checkout is missing shell or docker thresholds" >&2
  exit 1
fi

python3 - "${SHELL_FILE}" "${DOCKER_FILE}" << 'PY'
import pathlib
import sys

import yaml

shell = yaml.safe_load(pathlib.Path(sys.argv[1]).read_text())
docker = yaml.safe_load(pathlib.Path(sys.argv[2]).read_text())
shell_level = shell.get("shellcheck_failure_threshold")
hadolint_level = docker.get("hadolint_failure_threshold")
if shell_level in (None, ""):
    print("missing shellcheck_failure_threshold", file=sys.stderr)
    raise SystemExit(1)
if hadolint_level in (None, ""):
    print("missing hadolint_failure_threshold", file=sys.stderr)
    raise SystemExit(1)
rc = pathlib.Path(".shellcheckrc").read_text()
if f"severity={shell_level}" not in rc:
    print(f".shellcheckrc must set severity={shell_level}", file=sys.stderr)
    raise SystemExit(1)
pathlib.Path("/tmp/hadolint-failure-threshold").write_text(str(hadolint_level))
print(f"shellcheck_failure_threshold={shell_level}")
print(f"hadolint_failure_threshold={hadolint_level}")
PY

threshold="$(cat /tmp/hadolint-failure-threshold)"
rm -f /tmp/hadolint-failure-threshold

PATH="${HOME}/.local/bin:${PATH}"
export PATH
if ! command -v hadolint >/dev/null 2>&1; then
  echo "hadolint is not on PATH" >&2
  exit 1
fi

hadolint --failure-threshold "${threshold}" \
  .devcontainer/Dockerfile \
  molecule/ubuntu-accounts/Dockerfile \
  molecule/ubuntu-docker/Dockerfile \
  molecule/sles-accounts/Dockerfile \
  molecule/sles-docker/Dockerfile
