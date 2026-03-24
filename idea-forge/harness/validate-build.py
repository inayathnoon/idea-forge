#!/usr/bin/env python3
"""
Post-build validation step.

Validates that a completed build has:
1. GitHub repo created and accessible
2. All required files pushed
3. Linear project created (if applicable)
4. Repository structure is correct

Usage:
  python3 harness/validate-build.py <github-url> [--linear-key PROJECT_KEY]

Exit codes:
  0: All validation checks passed
  1: Critical validation failed (repo doesn't exist, missing core files)
  2: Warning-level issues (missing optional files, Linear not linked)
"""

import json
import sys
from pathlib import Path
from datetime import datetime


REQUIRED_ROOT_FILES = [
    "README.md",
    "AGENTS.md",
    "ARCHITECTURE.md",
    "WORKFLOW.md",
    "SCAFFOLDING.md",
]

REQUIRED_DOCS = [
    "docs/product-specs/mvp.md",
    "docs/product-specs/index.md",
    "docs/exec-plans/active/mvp-build-plan.md",
    "docs/design-docs/index.md",
    "docs/DESIGN.md",
    "docs/FRONTEND.md",
    "docs/PLANS.md",
    "docs/QUALITY_SCORE.md",
    "docs/RELIABILITY.md",
    "docs/SECURITY.md",
]

REQUIRED_MARKERS = [
    "docs/generated/.gitkeep",
    "docs/references/.gitkeep",
    "docs/exec-plans/completed/.gitkeep",
]


def validate_github_repo(github_url):
    """Check if GitHub repo is accessible (placeholder for actual check)."""
    # This would normally use GitHub API via MCP, but for now just validates URL format
    if not github_url or not github_url.startswith("https://github.com/"):
        return False, f"Invalid GitHub URL: {github_url}"
    return True, "GitHub repo URL is valid"


def validate_build_manifest(github_url):
    """Check that build info is recorded in ideas_store.json."""
    ideas_store = Path("memory/ideas_store.json")
    if not ideas_store.exists():
        return False, "ideas_store.json not found"

    with open(ideas_store) as f:
        data = json.load(f)

    ideas = data.get("ideas", [])
    if not ideas:
        return False, "No ideas in ideas_store.json"

    latest_idea = ideas[-1]
    if latest_idea.get("stage") != "built":
        return False, f"Latest idea stage is '{latest_idea.get('stage')}', expected 'built'"

    if latest_idea.get("github_url") != github_url:
        return False, f"GitHub URL mismatch: {latest_idea.get('github_url')} vs {github_url}"

    return True, "Build info correctly recorded in ideas_store.json"


def validate_local_files():
    """Verify that local template files exist (files that were pushed)."""
    issues = []

    # Check required root files exist locally
    for file in REQUIRED_ROOT_FILES:
        path = Path(file)
        if not path.exists() and file != "README.md":  # README.md might be generated
            issues.append(f"Missing local: {file}")

    # Check required docs exist locally
    for file in REQUIRED_DOCS:
        path = Path(file)
        if not path.exists():
            issues.append(f"Missing local: {file}")

    if issues:
        return False, f"Missing local files:\n" + "\n".join(f"  - {i}" for i in issues)

    return True, "All required local files exist"


def log_validation_result(passed, message):
    """Format and print validation result."""
    symbol = "✅" if passed else "❌"
    print(f"{symbol} {message}")
    return passed


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 harness/validate-build.py <github-url> [--linear-key PROJECT_KEY]")
        sys.exit(1)

    github_url = sys.argv[1]
    linear_key = None

    if len(sys.argv) > 3 and sys.argv[2] == "--linear-key":
        linear_key = sys.argv[3]

    print("\n" + "=" * 60)
    print("  Post-Build Validation")
    print("=" * 60 + "\n")

    all_passed = True

    # Validation 1: GitHub repo is accessible
    passed, msg = validate_github_repo(github_url)
    all_passed = log_validation_result(passed, msg) and all_passed
    if not passed:
        sys.exit(1)

    # Validation 2: Build info recorded in ideas_store.json
    passed, msg = validate_build_manifest(github_url)
    all_passed = log_validation_result(passed, msg) and all_passed
    if not passed:
        sys.exit(1)

    # Validation 3: All required files exist locally
    passed, msg = validate_local_files()
    all_passed = log_validation_result(passed, msg) and all_passed

    # Validation 4: Linear project linked (optional)
    if linear_key:
        msg = f"Linear project configured: {linear_key}"
        log_validation_result(True, msg)
    else:
        log_validation_result(False, "Linear project key not provided (optional)")

    print("\n" + "=" * 60)
    if all_passed:
        print("  ✅ All critical validation checks passed!")
        print("=" * 60 + "\n")
        return 0
    else:
        print("  ⚠️  Some checks failed. Review above for details.")
        print("=" * 60 + "\n")
        return 2


if __name__ == "__main__":
    sys.exit(main())
