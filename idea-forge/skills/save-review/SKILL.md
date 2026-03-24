---
name: save-review
description: Saves review to memory/ideas_store.json. Use when review agent has produced scores, verdict, and refined_mvp_features.
metadata:
  inputs: []
  outputs:
    - memory/ideas_store.json
  side_effects:
    - writes file
  called_by:
    - strategist
---

# Save Review

Read `memory/ideas_store.json`. Find the latest idea (last in the `ideas` array). Add the review object as a `review` field on that idea. Write the file back.

## Schema

```json
{
  "scores": { "clarity": 0, "feasibility": 0, "differentiation": 0, "completeness": 0 },
  "overall_score": 0,
  "strengths": [],
  "weaknesses": [],
  "risks": [],
  "improvements": [ { "area": "", "suggestion": "" } ],
  "verdict": "approved|revise|reject",
  "verdict_reason": "...",
  "refined_mvp_features": [ { "title": "", "description": "", "priority": "high|medium|low" } ]
}
```
