#!/usr/bin/env python3
"""Fail closed when the repo drifts from docs/guardrails/ansible/profile.thresholds.yml."""

from __future__ import annotations

import pathlib
import re
import shutil
import subprocess
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

    version = ansible_core_version()
    if version is None:
        print("ansible is not on PATH; cannot enforce ansible_core_min", file=sys.stderr)
        return 1
    if version_tuple(version) < version_tuple(str(data["ansible_core_min"])):
        print(f"ansible-core {version} is below ansible_core_min {data['ansible_core_min']}", file=sys.stderr)
        return 1

    platforms = set(data["supported_platforms"])
    for platform, scenarios in SCENARIOS.items():
        if platform not in platforms:
            print(f"supported_platforms missing {platform}", file=sys.stderr)
            return 1
        seen_roles: set[str] = set()
        for scenario in scenarios:
            scenario_dir = ROOT / "molecule" / scenario
            molecule_file = scenario_dir / "molecule.yml"
            if not molecule_file.is_file():
                print(f"missing molecule scenario {scenario}", file=sys.stderr)
                return 1
            scenario_data = yaml.safe_load(molecule_file.read_text())
            names = [item.get("name") for item in scenario_data.get("platforms", [])]
            if platform not in names:
                print(f"{scenario} platform name must be {platform}, found {names}", file=sys.stderr)
                return 1
            sequence = scenario_data.get("scenario", {}).get("test_sequence", [])
            converges = sequence.count("converge") + sequence.count("idempotence")
            if converges < int(data["idempotence_runs"]):
                print(
                    f"{scenario} has {converges} converges; idempotence_runs is {data['idempotence_runs']}",
                    file=sys.stderr,
                )
                return 1
            converge = (scenario_dir / "converge.yml").read_text()
            for role in ROLES:
                if f"name: {role}" in converge:
                    seen_roles.add(role)
        missing_roles = [role for role in ROLES if role not in seen_roles]
        if missing_roles:
            print(f"{platform} scenarios do not converge roles: {missing_roles}", file=sys.stderr)
            return 1
    print(f"ansible guardrail thresholds ok (ansible-core {version})")
    return 0


def ansible_core_version() -> str | None:
    ansible = shutil.which("ansible")
    if ansible is None:
        return None
    output = subprocess.check_output([ansible, "--version"], text=True)
    match = re.search(r"core (\d+\.\d+(?:\.\d+)?)", output)
    return match.group(1) if match else None


def version_tuple(value: str) -> tuple[int, ...]:
    return tuple(int(part) for part in value.split("."))


if __name__ == "__main__":
    raise SystemExit(main())
