#!/bin/sh
# Populate the docs/guardrails gitlink. GITHUB_TOKEN cannot read the private
# pirlruc/guardrails repository. The token is applied only to this command
# (CI-025: it is not written into git config).
set -eu

ROOT="$(git rev-parse --show-toplevel)"
cd "${ROOT}"

if [ -z "${GUARDRAILS_READ_TOKEN:-}" ]; then
  echo "GUARDRAILS_READ_TOKEN is required to fetch docs/guardrails" >&2
  exit 1
fi

git \
  -c "url.https://x-access-token:${GUARDRAILS_READ_TOKEN}@github.com/pirlruc/guardrails.git.insteadOf=https://github.com/pirlruc/guardrails.git" \
  submodule update --init docs/guardrails

test -f docs/guardrails/ansible/profile.thresholds.yml
echo "docs/guardrails $(git -C docs/guardrails rev-parse HEAD)"
