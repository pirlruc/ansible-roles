#!/bin/sh
# SC-DEP-004: gitlink SHA equals the peeled annotated tag named here.
# Fail closed when either gitlink drifts from the documented bootstrap ref.
set -eu

ROOT="$(git rev-parse --show-toplevel)"
cd "${ROOT}"

# Peeled commits: guardrails 1.15.0, github-scaffold 1.12.0.
GR_TAG="1.15.0"
GR_EXPECT="2d4bb70e95449f6922781716857adeb22badf676"
SC_TAG="1.12.0"
SC_EXPECT="9c443ea978851768f451b1df2020dd86dfb1a967"

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
