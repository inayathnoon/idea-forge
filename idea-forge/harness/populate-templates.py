#!/usr/bin/env python3
"""
Populate template placeholders by extracting info from BUILD_PLAN, ARCHITECTURE.md, and MVP spec.
Used by build-orchestrator before pushing files to GitHub.

Usage:
  python3 harness/populate-templates.py \
    --ideas-store memory/ideas_store.json \
    --mvp docs/product-specs/mvp.md \
    --architecture ARCHITECTURE.md \
    --build-plan docs/exec-plans/active/mvp-build-plan.md

Returns: JSON dict with all {placeholder} → value mappings
"""

import json
import sys
import argparse
import re
from pathlib import Path


def extract_title(text):
    """Extract first line or first heading from markdown."""
    for line in text.split('\n'):
        line = line.strip()
        if line and not line.startswith('#'):
            return line
        if line.startswith('# '):
            return line.replace('# ', '').strip()
    return ""


def extract_from_ideas_store(ideas_store_path):
    """Extract idea name from ideas_store.json."""
    with open(ideas_store_path) as f:
        data = json.load(f)
    ideas = data.get('ideas', [])
    if not ideas:
        return {}
    latest = ideas[-1]  # Last idea in the list
    return {
        'project_name': latest.get('name', 'project'),
        'full_name': latest.get('full_name', latest.get('name', 'project')),
    }


def extract_from_mvp(mvp_path):
    """Extract one-line description from MVP spec."""
    with open(mvp_path) as f:
        text = f.read()
    # Look for first paragraph after heading
    lines = text.split('\n')
    for i, line in enumerate(lines):
        if line.startswith('# '):
            # Get first non-empty line after heading
            for j in range(i+1, len(lines)):
                if lines[j].strip() and not lines[j].startswith('#'):
                    return lines[j].strip()
    return "A project built with IdeaForge"


def extract_from_architecture(arch_path):
    """Extract tech stack, frameworks, commands from ARCHITECTURE.md."""
    with open(arch_path) as f:
        text = f.read()

    result = {}

    # Look for tech stack section
    tech_match = re.search(r'## Tech Stack.*?\n(.*?)(?=\n##|\Z)', text, re.DOTALL)
    if tech_match:
        tech_section = tech_match.group(1)
        # Extract framework/language
        if 'Node.js' in tech_section or 'JavaScript' in tech_section or 'TypeScript' in tech_section:
            result['framework'] = 'Node.js / React'
            result['test_command'] = 'npm test'
            result['dev_command'] = 'npm run dev'
            result['lockfile'] = 'package-lock.json'
            result['add_command'] = 'npm install'
            result['build_command'] = 'npm run build'
        elif 'Python' in tech_section:
            result['framework'] = 'Python'
            result['test_command'] = 'pytest'
            result['dev_command'] = 'python -m uvicorn main:app --reload'
            result['lockfile'] = 'requirements.txt'
            result['add_command'] = 'pip install'
            result['build_command'] = 'python -m build'
        elif 'Go' in tech_section:
            result['framework'] = 'Go'
            result['test_command'] = 'go test ./...'
            result['dev_command'] = 'go run .'
            result['lockfile'] = 'go.mod'
            result['add_command'] = 'go get'
            result['build_command'] = 'go build'
        else:
            result['framework'] = 'See ARCHITECTURE.md'
            result['test_command'] = '{see ARCHITECTURE.md}'
            result['dev_command'] = '{see ARCHITECTURE.md}'
            result['lockfile'] = '{see ARCHITECTURE.md}'
            result['add_command'] = '{see ARCHITECTURE.md}'
            result['build_command'] = '{see ARCHITECTURE.md}'

    # Extract naming convention if present
    conv_match = re.search(r'## Naming.*?\n(.*?)(?=\n##|\Z)', text, re.DOTALL)
    if conv_match:
        result['convention'] = 'See ARCHITECTURE.md for naming conventions'
    else:
        result['convention'] = 'camelCase for variables/functions, PascalCase for classes/components'

    # Extract test directory if present
    result['test_dir'] = '__tests__' if 'test' in text.lower() else 'tests'

    return result


def extract_from_build_plan(plan_path):
    """Extract patterns and first task from BUILD_PLAN."""
    with open(plan_path) as f:
        text = f.read()

    result = {}

    # Extract patterns/conventions section
    patterns_match = re.search(r'## Patterns.*?\n(.*?)(?=\n##|\Z)', text, re.DOTALL)
    if patterns_match:
        result['patterns'] = patterns_match.group(1).strip()
    else:
        result['patterns'] = "See ARCHITECTURE.md and DESIGN.md for patterns"

    # Extract folder structure if present
    struct_match = re.search(r'## Folder.*?\n(.*?)(?=\n##|\Z)', text, re.DOTALL)
    if struct_match:
        result['folder_structure'] = struct_match.group(1).strip()
    else:
        result['folder_structure'] = "See ARCHITECTURE.md and SCAFFOLDING.md"

    return result


def populate_templates(ideas_store, mvp_spec, architecture, build_plan):
    """Merge all extracted values into one mapping."""
    data = {}

    if ideas_store:
        data.update(extract_from_ideas_store(ideas_store))
    if mvp_spec:
        data['one_line_description'] = extract_from_mvp(mvp_spec)
    if architecture:
        data.update(extract_from_architecture(architecture))
    if build_plan:
        data.update(extract_from_build_plan(build_plan))

    # Set defaults for missing values
    defaults = {
        'project_name': 'project',
        'full_name': 'Project',
        'one_line_description': 'A project built with IdeaForge',
        'framework': 'Node.js',
        'test_command': 'npm test',
        'dev_command': 'npm run dev',
        'test_dir': '__tests__',
        'convention': 'camelCase for functions, PascalCase for classes',
        'ISSUE_ID': 'INO',
        'lockfile': 'package-lock.json',
        'add_command': 'npm install',
        'build_command': 'npm run build',
        'install_command': 'npm install',
        'patterns': 'See ARCHITECTURE.md and DESIGN.md',
        'folder_structure': 'See ARCHITECTURE.md',
    }

    for key, val in defaults.items():
        if key not in data:
            data[key] = val

    return data


def main():
    parser = argparse.ArgumentParser(description='Extract placeholder values for templates')
    parser.add_argument('--ideas-store', help='Path to ideas_store.json')
    parser.add_argument('--mvp', help='Path to MVP spec')
    parser.add_argument('--architecture', help='Path to ARCHITECTURE.md')
    parser.add_argument('--build-plan', help='Path to BUILD_PLAN')
    parser.add_argument('--output', help='Output format: json (default) or python')

    args = parser.parse_args()

    # Verify files exist
    for path_arg in ['ideas_store', 'mvp', 'architecture', 'build_plan']:
        path = getattr(args, path_arg)
        if path and not Path(path).exists():
            print(f"ERROR: {path_arg} file not found: {path}", file=sys.stderr)
            sys.exit(1)

    # Extract
    data = populate_templates(
        args.ideas_store,
        args.mvp,
        args.architecture,
        args.build_plan
    )

    # Output
    if args.output == 'python' or args.output == 'dict':
        # Output as Python dict for use in scripts
        print(json.dumps(data, indent=2))
    else:
        # Default: JSON
        print(json.dumps(data, indent=2))

    return 0


if __name__ == '__main__':
    sys.exit(main())
