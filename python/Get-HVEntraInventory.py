#!/usr/bin/env python3

import argparse
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def run_az(*args):
    result = subprocess.run(
        ["az", *args, "--output", "json"],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="HV-Entra-Inventory.json",
        help="Path for the local report",
    )
    args = parser.parse_args()

    account = run_az("account", "show")
    users = run_az("ad", "user", "list", "--all")
    groups = run_az("ad", "group", "list", "--all")

    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "tenant_id": account.get("tenantId"),
        "subscription_name": account.get("name"),
        "users": len(users),
        "groups": len(groups),
        "enabled_users": sum(
            1 for user in users if user.get("accountEnabled") is True
        ),
        "security_groups": sum(
            1 for group in groups if group.get("securityEnabled") is True
        ),
    }

    output_path = Path(args.output)
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print(f"Inventory written to {output_path}")
    print(f"Users: {report['users']}")
    print(f"Groups: {report['groups']}")
    print(f"Enabled users: {report['enabled_users']}")
    print(f"Security groups: {report['security_groups']}")


if __name__ == "__main__":
    main()
