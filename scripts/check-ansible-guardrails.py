#!/usr/bin/env python3
"""Fail closed when the repo drifts from docs/guardrails/ansible/profile.thresholds.yml."""

from __future__ import annotations

import pathlib
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
THRESHOLDS = ROOT / "docs" / "guardrails" / "ansible" / "profile.thresholds.yml"
ROLES = ("docker", "users", "permissions", "group_membership")
SCENARIOS = {
    "ubuntu-26.04": ("ubuntu-accounts", "ubuntu-docker"),
    "sles-16": ("sles-accounts", "sles-docker"),
}


def main() -> int:
    if not THRESHOLDS.is_file():
        print(f"missing thresholds: {THRESHOLDS}", file=sys.stderr)
        return 1
    data = yaml.safe_load(THRESHOLDS.read_text())
    required = ("ansible_core_min", "ansible_lint_profile", "idempotence_runs", "supported_platforms")
    missing = [key for key in required if key not in data or data[key] in (None, "", [])]
    if missing:
        print(f"thresholds missing keys: {missing}", file=sys.stderr)
        return 1
    if int(data["idempotence_runs"]) < 2:
        print("idempotence_runs must be at least 2", file=sys.stderr)
        return 1

    lint = (ROOT / ".ansible-lint").read_text()
    profile = str(data["ansible_lint_profile"])
    if f"profile: {profile}" not in lint:
        print(f".ansible-lint must set profile: {profile}", file=sys.stderr)
        return 1

    for role in ROLES:
        base = ROOT / "roles" / role
        for relative in ("README.md", "meta/main.yml", "meta/argument_specs.yml", "tasks/main.yml"):
            if not (base / relative).is_file():
                print(f"{role} missing {relative}", file=sys.stderr)
                return 1
        meta = (base / "meta" / "main.yml").read_text()
        if "dependencies: []" not in meta:
            print(f"{role} must keep dependencies: [] (compose roles from the orchestrator)", file=sys.stderr)
            return 1

    platforms = set(data["supported_platforms"])
    for platform, scenarios in SCENARIOS.items():
        if platform not in platforms:
            print(f"supported_platforms missing {platform}", file=sys.stderr)
            return 1
        for scenario in scenarios:
            if not (ROOT / "molecule" / scenario / "molecule.yml").is_file():
                print(f"missing molecule scenario {scenario}", file=sys.stderr)
                return 1
    print("ansible guardrail thresholds ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
