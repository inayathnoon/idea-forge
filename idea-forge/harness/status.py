#!/usr/bin/env python3
"""
Show pipeline status for the current idea.

Usage:
  python3 harness/status.py [ideas_store_path]

Displays:
- Current idea name and full name
- Current stage
- What stage comes next
- Required documents for next stage
- Progress through pipeline
"""

import json
import sys
from pathlib import Path
from datetime import datetime


def get_stage_info(pipeline, stage):
    """Get info about a stage from pipeline.json."""
    return pipeline.get("states", {}).get(stage, {})


def get_next_transition(pipeline, current_stage):
    """Get the next transition from current stage."""
    for t in pipeline.get("transitions", []):
        if t.get("from") == current_stage:
            return t
    return None


def show_status(ideas_store_path, pipeline_path):
    """Display pipeline status for current idea."""
    # Load files
    with open(ideas_store_path) as f:
        ideas_store = json.load(f)

    with open(pipeline_path) as f:
        pipeline = json.load(f)

    ideas = ideas_store.get("ideas", [])
    if not ideas:
        print("❌ No ideas in ideas_store.json")
        return 1

    idea = ideas[-1]  # Latest idea
    stage = idea.get("stage", "raw")

    # Calculate progress
    all_stages = [
        "raw", "captured", "explored", "reviewed",
        "researched", "prd_written", "arch_written",
        "plan_written", "built"
    ]
    current_idx = all_stages.index(stage) if stage in all_stages else 0
    progress = f"{current_idx + 1}/{len(all_stages)}"

    # Get stage info
    stage_info = get_stage_info(pipeline, stage)
    next_transition = get_next_transition(pipeline, stage)

    # Display
    print(f"\n{'='*60}")
    print(f"  IdeaForge Pipeline Status")
    print(f"{'='*60}\n")

    print(f"📌 Idea: {idea.get('full_name', idea.get('name', 'Unknown'))}")
    print(f"   Slug: {idea.get('name')}")
    if idea.get("github_url"):
        print(f"   Repo: {idea.get('github_url')}")

    print(f"\n📊 Stage Progress: {progress}")
    print(f"   Current: {stage.upper()}")
    print(f"   {stage_info.get('description', '')}")

    # Check review verdict if in reviewed stage
    if stage == "reviewed":
        verdict = idea.get("review", {}).get("verdict")
        if verdict == "approved":
            print(f"   ✅ Verdict: {verdict} → Moving to Research")
        elif verdict == "revise":
            print(f"   ⚠️  Verdict: {verdict} → Back to Capture")
        elif verdict == "reject":
            print(f"   ❌ Verdict: {verdict} → Rejected")
        else:
            print(f"   ❓ No verdict yet")

    # Next stage
    if next_transition:
        next_stage = next_transition.get("to")
        next_agent = next_transition.get("agent")
        next_stage_info = get_stage_info(pipeline, next_stage)

        print(f"\n→ Next Step: {next_stage.upper()}")
        print(f"   Agent: {next_agent}")
        print(f"   {next_stage_info.get('description', '')}")

        # Required outputs for next stage
        next_artifacts = next_stage_info.get("artifacts", [])
        if next_artifacts:
            print(f"\n   Outputs needed:")
            for artifact in next_artifacts[:3]:  # Show first 3
                if not artifact.startswith("memory/ideas_store.json#"):
                    print(f"     - {artifact}")
    else:
        print(f"\n✅ Pipeline Complete!")

    # Timestamps
    created = idea.get("created_at", "unknown")
    updated = idea.get("updated_at", "unknown")
    print(f"\n📅 Created: {created}")
    print(f"   Updated: {updated}")

    print(f"\n{'='*60}\n")
    return 0


def main():
    ideas_store = "memory/ideas_store.json"
    pipeline = "harness/pipeline.json"

    if len(sys.argv) > 1:
        ideas_store = sys.argv[1]

    if not Path(ideas_store).exists():
        print(f"❌ File not found: {ideas_store}")
        return 1

    if not Path(pipeline).exists():
        print(f"❌ File not found: {pipeline}")
        return 1

    return show_status(ideas_store, pipeline)


if __name__ == "__main__":
    sys.exit(main())
