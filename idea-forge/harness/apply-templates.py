#!/usr/bin/env python3
"""
Apply placeholder population to template files.

This script:
1. Gets placeholder mapping from populate-templates.py
2. Reads a template file
3. Replaces {placeholder} with values from the mapping
4. Outputs the populated content

Usage:
  python3 harness/apply-templates.py <template-file> \
    --ideas-store memory/ideas_store.json \
    --mvp docs/product-specs/mvp.md \
    --architecture ARCHITECTURE.md \
    --build-plan docs/exec-plans/active/mvp-build-plan.md

Returns: Populated template content (stdout)

Example:
  python3 harness/apply-templates.py templates/AGENTS.md \
    --ideas-store memory/ideas_store.json \
    --mvp docs/product-specs/mvp.md \
    --architecture ARCHITECTURE.md \
    --build-plan docs/exec-plans/active/mvp-build-plan.md
"""

import json
import sys
import argparse
import re
import subprocess
from pathlib import Path


def get_placeholder_mapping(ideas_store, mvp_spec, architecture, build_plan):
    """
    Call populate-templates.py to get placeholder mapping.

    Returns dict of {placeholder} → value
    """
    cmd = [
        "python3",
        "harness/populate-templates.py",
    ]

    if ideas_store:
        cmd.extend(["--ideas-store", ideas_store])
    if mvp_spec:
        cmd.extend(["--mvp", mvp_spec])
    if architecture:
        cmd.extend(["--architecture", architecture])
    if build_plan:
        cmd.extend(["--build-plan", build_plan])

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"ERROR: populate-templates.py failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as e:
        print(f"ERROR: Failed to parse populate-templates output: {e}", file=sys.stderr)
        sys.exit(1)


def apply_placeholders(content, mapping):
    """
    Replace all {placeholder} with values from mapping.

    Handles:
    - {placeholder} → value (exact match)
    - {placeholder_missing} → placeholder remains unchanged
    """
    result = content

    for key, value in mapping.items():
        # Handle both {key} and {KEY} variants
        placeholder = "{" + key + "}"
        placeholder_upper = "{" + key.upper() + "}"

        result = result.replace(placeholder, str(value))
        result = result.replace(placeholder_upper, str(value))

    return result


def main():
    parser = argparse.ArgumentParser(description='Apply template population to a file')
    parser.add_argument('template_file', help='Path to template file to populate')
    parser.add_argument('--ideas-store', help='Path to ideas_store.json')
    parser.add_argument('--mvp', help='Path to MVP spec')
    parser.add_argument('--architecture', help='Path to ARCHITECTURE.md')
    parser.add_argument('--build-plan', help='Path to BUILD_PLAN')
    parser.add_argument('--debug', action='store_true', help='Print debug info')

    args = parser.parse_args()

    # Check template file exists
    template_path = Path(args.template_file)
    if not template_path.exists():
        print(f"ERROR: Template file not found: {args.template_file}", file=sys.stderr)
        sys.exit(1)

    # Read template
    with open(template_path) as f:
        content = f.read()

    # Get placeholder mapping
    mapping = get_placeholder_mapping(
        args.ideas_store,
        args.mvp,
        args.architecture,
        args.build_plan
    )

    if args.debug:
        print(f"DEBUG: Placeholder mapping: {json.dumps(mapping, indent=2)}", file=sys.stderr)

    # Apply placeholders
    populated = apply_placeholders(content, mapping)

    # Output
    print(populated, end='')

    return 0


if __name__ == '__main__':
    sys.exit(main())
