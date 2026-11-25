#!/bin/sh
# SC-DEP-004: gitlink SHA equals the peeled annotated tag named here.
# Fail closed when either gitlink drifts from the documented bootstrap ref.
set -eu

ROOT="$(git rev-parse --show-toplevel)"
cd "${ROOT}"

# Peeled commits: guardrails 1.17.1, github-scaffold 1.14.3.
GR_TAG="1.17.1"
GR_EXPECT="8508e93691aa3c4f769ecc215ddc83ecf26e70b2"
SC_TAG="1.14.3"
SC_EXPECT="1fca8a3b79c10d38d5b39747d2363070a07503da"

gr="$(git rev-parse ':docs/guardrails')"
sc="$(git rev-parse ':.github/scaffold')"

status=0
if [ "${gr}" != "${GR_EXPECT}" ]; then
  echo "SC-DEP-004: docs/guardrails gitlink ${gr} != ${GR_TAG} ${GR_EXPECT}" >&2
  status=1
fi
if [ "${sc}" != "${SC_EXPECT}" ]; then
  echo "SC-DEP-004: .github/scaffold gitlink ${sc} != ${SC_TAG} ${SC_EXPECT}" >&2
  status=1
fi
if [ "${status}" -ne 0 ]; then
  exit 1
fi

echo "SC-DEP-004: docs/guardrails @ ${GR_TAG} (${GR_EXPECT})"
echo "SC-DEP-004: .github/scaffold @ ${SC_TAG} (${SC_EXPECT})"
