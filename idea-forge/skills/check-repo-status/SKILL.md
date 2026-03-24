---
name: check-repo-status
description: Checks actual GitHub repo state (commits, issues, PRs, branches) for real-time context. Used by /pick-another and /existing-idea to ground idea status in reality, not just planned state.
metadata:
  inputs:
    - github_url: string (e.g., "https://github.com/inayathnoon/learnbridge")
    - idea_slug: string (for matching to memory)
  outputs:
    - repo_status: object (commits count, latest commit, open/closed issues, PR state)
    - divergence: array (places where repo state differs from ideas_store.json)
  side_effects: []
  called_by:
    - pick-another command
    - existing-idea command
---

# Check Repo Status Skill

Fetch real-time GitHub repo state to ground decision-making in what actually happened, not what was planned.

## Purpose

- **Ground truth**: Know what's actually in the repo (commits, branches, issues)
- **Detect divergence**: Spot when ideas_store.json doesn't match reality
- **Update strategy**: If repo is ahead of plan or behind, adjust next steps
- **Avoid stale data**: Don't assume stage N is complete if repo shows work isn't finished

## Inputs Required

| Field | Type | Example | Notes |
|-------|------|---------|-------|
| `github_url` | string | `https://github.com/inayathnoon/learnbridge` | Repository URL |
| `idea_slug` | string | `learnbridge` | For matching to ideas_store.json state |

## Output Format

```json
{
  "repo_status": {
    "url": "https://github.com/inayathnoon/learnbridge",
    "default_branch": "main",
    "latest_commit": {
      "sha": "a1b2c3d4",
      "message": "Add authentication flow",
      "date": "2026-03-24T10:30:00Z",
      "author": "Inayath Noon"
    },
    "total_commits": 47,
    "branches": {
      "main": "a1b2c3d4",
      "develop": "e5f6g7h8",
      "feature/auth": "i9j0k1l2"
    },
    "issues": {
      "open": 5,
      "closed": 23,
      "recent_open": [
        {
          "number": 12,
          "title": "Add user profiles",
          "created": "2026-03-20T14:00:00Z"
        }
      ]
    },
    "pull_requests": {
      "open": 2,
      "merged": 18,
      "recent_pr": {
        "number": 45,
        "title": "Implement database migrations",
        "merged_at": "2026-03-23T15:30:00Z"
      }
    },
    "tags": ["v0.1.0", "v0.2.0", "v0.3.0"],
    "description": "CBSE learning app with parent alerts via WhatsApp"
  },
  "divergence": [
    {
      "type": "ahead",
      "message": "Repo has 5 open issues, but ideas_store.json shows stage=built (no outstanding work expected)"
    },
    {
      "type": "behind",
      "message": "Latest commit is authentication (stage 6?), but ideas_store.json shows stage=prd_written"
    },
    {
      "type": "stale",
      "message": "ideas_store.json updated 10 days ago, latest commit 2 days ago"
    }
  ]
}
```

## Implementation Notes

Use GitHub API or gh CLI:

```bash
gh repo view <owner>/<repo> --json nameWithOwner,description,defaultBranchRef,commits,issues,pullRequests
gh api repos/<owner>/<repo>/commits --paginate | head -50
gh issue list -R <owner>/<repo> --state all
gh pr list -R <owner>/<repo> --state all
```

## Divergence Detection

Compare repo state to ideas_store.json:

| Signal | What It Means | Action |
|--------|---------------|--------|
| More commits than expected | Work happened, maybe not in memory | Update ideas_store.json |
| Open issues but stage=built | Unresolved work after "launch" | Clarify if truly complete |
| No recent commits + old stage | Stale data, maybe abandoned | Check if project is still active |
| PR count > ideas_store issues | Work in flight not tracked | Sync issues to ideas_store |
| Tags not in ideas_store | Releases happened without logging | Add to version history |

## Example Usage

Called by /pick-another to show real status:

```bash
check-repo-status \
  --github-url "https://github.com/inayathnoon/learnbridge" \
  --idea-slug "learnbridge"
```

Returns:
```
Repository Status: learnbridge

Latest: 47 commits, "Add authentication flow" (2 days ago)
Issues: 5 open, 23 closed
PRs: 2 open, 18 merged

⚠️ Divergence detected:
  - Repo shows open issues, but ideas_store says stage=built
  - Ideas store is 10 days stale
```

## Fallback Strategies

**If repo is private**: Can't access — skip real-time check, warn user

**If GitHub API fails**: Log warning, use last-known state from memory

**If no repo yet**: Show "not yet created" and suggest next steps
