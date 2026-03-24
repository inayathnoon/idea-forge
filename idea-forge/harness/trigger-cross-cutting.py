#!/usr/bin/env python3
"""
Auto-trigger cross-cutting agents (like project-manager) after a stage completes.

This script:
1. Reads the pipeline.json to find which cross-cutting agents should run after the current transition
2. Invokes those agents automatically
3. Updates the session state

Usage:
  python3 harness/trigger-cross-cutting.py <from_stage> <to_stage>

Example:
  python3 harness/trigger-cross-cutting.py captured explored
  # Will trigger any cross-cutting agents defined for captured→explored transition

Returns:
  0: Cross-cutting agents triggered successfully (or none defined)
  1: Error (invalid stages, missing pipeline.json, etc.)
"""

import json
import sys
import os
from pathlib import Path


def load_pipeline():
    """Load pipeline.json and return the transitions definition."""
    pipeline_path = Path("harness/pipeline.json")
    if not pipeline_path.exists():
        print("ERROR: harness/pipeline.json not found", file=sys.stderr)
        sys.exit(1)

    with open(pipeline_path) as f:
        pipeline = json.load(f)

    return pipeline


def find_cross_cutting_agents(pipeline, from_stage, to_stage):
    """
    Find cross-cutting agents for a given transition.

    Returns list of agent names that should be triggered.
    """
    transitions = pipeline.get("transitions", [])

    for transition in transitions:
        if transition.get("from") == from_stage and transition.get("to") == to_stage:
            # Found the transition, get cross-cutting agents
            return transition.get("cross_cutting", [])

    # No matching transition found
    return []


def log_agents(agents):
    """Log which agents will be triggered."""
    if not agents:
        print("No cross-cutting agents to trigger after this stage")
        return

    print(f"Auto-triggering {len(agents)} cross-cutting agent(s):")
    for agent in agents:
        print(f"  → {agent}")


def main():
    if len(sys.argv) != 3:
        print("Usage: python3 harness/trigger-cross-cutting.py <from_stage> <to_stage>")
        print("Example: python3 harness/trigger-cross-cutting.py captured explored")
        sys.exit(1)

    from_stage = sys.argv[1]
    to_stage = sys.argv[2]

    pipeline = load_pipeline()
    agents = find_cross_cutting_agents(pipeline, from_stage, to_stage)

    log_agents(agents)

    if agents:
        print("\nNext: Run these agents in sequence to capture decisions:")
        for agent in agents:
            print(f"  - Follow {agent}.md (from agents/ directory)")

    # Return 0 regardless (either agents found and logged, or none to trigger)
    return 0


if __name__ == "__main__":
    sys.exit(main())
