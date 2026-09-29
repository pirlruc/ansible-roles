#!/bin/sh
# Host install of the lint binaries commondevops 5.1.2 pins in
# scripts/install-common-tools.sh. Versions and SHA256 digests match that tag
# (b3c462bed0de4f6475e6be7875c4ababd831acc6). This repo cannot call the private
# reusable workflow; see docs/ai-agent-handoff.md.
set -eu

HADOLINT_VERSION="2.12.0"
HADOLINT_SHA256="56de6d5e5ec427e17b74fa48d51271c7fc0d61244bf5c90e828aab8362d55010"
ACTIONLINT_VERSION="1.7.12"
ACTIONLINT_SHA256="8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8"
SHELLCHECK_VERSION="0.10.0"
SHELLCHECK_SHA256="6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87"

DEST="${HOME}/.local/bin"
mkdir -p "${DEST}"

verify_sha256() {
  file="$1"
  expect="$2"
  actual="$(sha256sum "${file}" | awk '{print $1}')"
  if [ "${actual}" != "${expect}" ]; then
    echo "checksum mismatch for ${file}" >&2
    exit 1
  fi
}

if ! command -v hadolint >/dev/null 2>&1; then
  curl -fsSL -o /tmp/hadolint \
    "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64"
  verify_sha256 /tmp/hadolint "${HADOLINT_SHA256}"
  install -m 755 /tmp/hadolint "${DEST}/hadolint"
  rm -f /tmp/hadolint
fi

if ! command -v actionlint >/dev/null 2>&1; then
  curl -fsSL -o /tmp/actionlint.tgz \
    "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz"
  verify_sha256 /tmp/actionlint.tgz "${ACTIONLINT_SHA256}"
  tar -xzf /tmp/actionlint.tgz -C "${DEST}" actionlint
  chmod +x "${DEST}/actionlint"
  rm -f /tmp/actionlint.tgz
fi

if ! command -v shellcheck >/dev/null 2>&1; then
  curl -fsSL -o /tmp/shellcheck.txz \
    "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"
  verify_sha256 /tmp/shellcheck.txz "${SHELLCHECK_SHA256}"
  tar -xJf /tmp/shellcheck.txz -C /tmp "shellcheck-v${SHELLCHECK_VERSION}/shellcheck"
  install -m 755 "/tmp/shellcheck-v${SHELLCHECK_VERSION}/shellcheck" "${DEST}/shellcheck"
  rm -rf /tmp/shellcheck.txz "/tmp/shellcheck-v${SHELLCHECK_VERSION}"
fi

if [ -n "${GITHUB_PATH:-}" ]; then
  echo "${DEST}" >> "${GITHUB_PATH}"
fi

export PATH="${DEST}:${PATH}"
echo "lint tools: $(command -v shellcheck) $(command -v actionlint) $(command -v hadolint)"
