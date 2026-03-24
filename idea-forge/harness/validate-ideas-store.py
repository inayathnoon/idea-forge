#!/usr/bin/env python3
"""
Validate ideas_store.json against its JSON Schema.

Usage:
  python3 harness/validate-ideas-store.py memory/ideas_store.json

Returns:
  0 if valid
  1 if invalid, printing validation errors
"""

import json
import sys
from pathlib import Path

try:
    import jsonschema
except ImportError:
    print("ERROR: jsonschema not installed. Install with: pip install jsonschema", file=sys.stderr)
    sys.exit(1)


def validate(ideas_store_path, schema_path):
    """Validate ideas_store.json against schema."""
    # Load ideas store
    with open(ideas_store_path) as f:
        ideas_store = json.load(f)

    # Load schema
    with open(schema_path) as f:
        schema = json.load(f)

    # Validate
    try:
        jsonschema.validate(instance=ideas_store, schema=schema)
        return True, "ideas_store.json is valid"
    except jsonschema.ValidationError as e:
        return False, f"Validation error: {e.message}\nPath: {list(e.path)}"
    except jsonschema.SchemaError as e:
        return False, f"Schema error: {e.message}"


def main():
    if len(sys.argv) < 2:
        print("Usage: validate-ideas-store.py <path/to/ideas_store.json>", file=sys.stderr)
        sys.exit(1)

    ideas_store_path = sys.argv[1]
    schema_path = str(Path(ideas_store_path).parent / "ideas_store.schema.json")

    # Check files exist
    if not Path(ideas_store_path).exists():
        print(f"ERROR: File not found: {ideas_store_path}", file=sys.stderr)
        sys.exit(1)

    if not Path(schema_path).exists():
        print(f"ERROR: Schema file not found: {schema_path}", file=sys.stderr)
        sys.exit(1)

    # Validate
    valid, message = validate(ideas_store_path, schema_path)
    print(message)

    return 0 if valid else 1


if __name__ == '__main__':
    sys.exit(main())
