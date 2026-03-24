#!/usr/bin/env python3
"""
Collect user feedback on agent outputs after each stage.

Captures user ratings (thumbs up/down/neutral) and notes on what worked well
and what needs improvement. This informs playbook updates and agent refinements.

Usage:
  python3 harness/feedback.py <stage_name> [--auto]

Examples:
  python3 harness/feedback.py captured
  # Prompts user: "How did idea-capturer-1 do?"

  python3 harness/feedback.py reviewed --auto
  # Saves neutral feedback automatically (for CI/headless mode)
"""

import json
import sys
from pathlib import Path
from datetime import datetime


FEEDBACK_LOG = Path("memory/feedback.json")


def load_feedback_log():
    """Load existing feedback log or create empty one."""
    if FEEDBACK_LOG.exists():
        with open(FEEDBACK_LOG) as f:
            return json.load(f)
    return {"feedback": []}


def save_feedback_log(log):
    """Save feedback log."""
    FEEDBACK_LOG.parent.mkdir(parents=True, exist_ok=True)
    with open(FEEDBACK_LOG, "w") as f:
        json.dump(log, f, indent=2)


def get_user_feedback(stage_name):
    """
    Prompt user for feedback on this stage's agent output.

    Returns dict with rating, notes, and suggestions.
    """
    print(f"\n{'='*60}")
    print(f"  Feedback: {stage_name} Stage")
    print(f"{'='*60}\n")

    print("How did the agent output meet your expectations?\n")

    # Get rating
    while True:
        rating_input = input(
            "Rate it (👍 thumbs_up / 👎 thumbs_down / 😐 neutral): "
        ).strip().lower()

        if rating_input in ["👍", "thumbs_up", "up", "good", "yes"]:
            rating = "thumbs_up"
            break
        elif rating_input in ["👎", "thumbs_down", "down", "bad", "no"]:
            rating = "thumbs_down"
            break
        elif rating_input in ["😐", "neutral", "ok", "meh"]:
            rating = "neutral"
            break
        else:
            print("Please enter: thumbs_up, thumbs_down, or neutral\n")

    # Get notes
    print("\nWhat worked well? (optional, press Enter to skip)")
    notes_good = input("> ").strip()

    print("\nWhat needs improvement? (optional, press Enter to skip)")
    notes_bad = input("> ").strip()

    print("\nAny specific suggestions? (optional)")
    suggestions_input = input("> ").strip()
    suggestions = [s.strip() for s in suggestions_input.split(",") if s.strip()]

    print(f"\n✅ Feedback recorded for {stage_name}\n")

    return {
        "rating": rating,
        "notes_positive": notes_good or None,
        "notes_negative": notes_bad or None,
        "suggestions": suggestions if suggestions else None,
    }


def record_feedback(stage_name, feedback):
    """Save feedback to log."""
    log = load_feedback_log()

    entry = {
        "stage": stage_name,
        "timestamp": datetime.now().isoformat(),
        "rating": feedback["rating"],
        "notes_positive": feedback.get("notes_positive"),
        "notes_negative": feedback.get("notes_negative"),
        "suggestions": feedback.get("suggestions"),
    }

    log["feedback"].append(entry)
    save_feedback_log(log)

    return entry


def summarize_feedback():
    """Print summary of collected feedback."""
    if not FEEDBACK_LOG.exists():
        print("No feedback collected yet")
        return

    log = load_feedback_log()
    feedback_list = log.get("feedback", [])

    if not feedback_list:
        print("No feedback entries")
        return

    print("\n" + "=" * 60)
    print("  Feedback Summary")
    print("=" * 60 + "\n")

    # Count ratings by stage
    by_stage = {}
    for entry in feedback_list:
        stage = entry["stage"]
        if stage not in by_stage:
            by_stage[stage] = {"thumbs_up": 0, "thumbs_down": 0, "neutral": 0}
        by_stage[stage][entry["rating"]] += 1

    # Print per stage
    for stage in sorted(by_stage.keys()):
        counts = by_stage[stage]
        total = sum(counts.values())
        print(f"{stage.upper()} (n={total})")
        print(f"  👍 {counts['thumbs_up']}")
        print(f"  👎 {counts['thumbs_down']}")
        print(f"  😐 {counts['neutral']}")
        print()

    # Aggregate suggestions
    all_suggestions = []
    for entry in feedback_list:
        if entry.get("suggestions"):
            all_suggestions.extend(entry["suggestions"])

    if all_suggestions:
        print("Top suggestions:")
        from collections import Counter
        suggestion_counts = Counter(all_suggestions)
        for sugg, count in suggestion_counts.most_common(5):
            print(f"  • {sugg} ({count}x)")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 harness/feedback.py <stage_name> [--auto] [--summary]")
        print("Examples:")
        print("  python3 harness/feedback.py captured")
        print("  python3 harness/feedback.py reviewed --auto")
        print("  python3 harness/feedback.py --summary")
        sys.exit(1)

    if sys.argv[1] == "--summary":
        summarize_feedback()
        return 0

    stage_name = sys.argv[1]
    auto_mode = "--auto" in sys.argv

    if auto_mode:
        # Auto mode: save neutral feedback without prompting
        feedback = {
            "rating": "neutral",
            "notes_positive": None,
            "notes_negative": None,
            "suggestions": None,
        }
        print(f"Recording neutral feedback for {stage_name} (auto mode)")
    else:
        # Interactive mode: ask user
        feedback = get_user_feedback(stage_name)

    entry = record_feedback(stage_name, feedback)
    print(f"Saved to: {FEEDBACK_LOG}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
