# /pick-another — Pick Another Direction to Build

Show all 10 explored directions for the current idea, mark which ones have been built, and recommend what to build next.

## Process

### 1. Load Idea
Read `memory/ideas_store.json` to get the current idea's `name` and exploration data.

### 2. Find Explorations
Read `idea_storage/{slug}-{timestamp}/` to get all 10 directions that were explored in stage 2.

### 3. Show Directions
Display all 10 directions with:
- Direction name and one-line description
- Whether it was the selected direction
- Whether it's been built (check if `github_url` exists for it)
- The top 3 that were shortlisted

### 4. Recommend
Based on the strategist's scores and what's already been built, recommend the next best direction to build.

### 5. User Picks
Let the user choose a direction. Once chosen:
- Update `memory/ideas_store.json` with the new selected direction
- Reset the idea stage to `reviewed` (skips capture + explore, keeps the review)
- Tell user to run `/advance` to start from researcher-4

This creates a new repo for the same idea but with a different direction — reusing the structured idea and exploration work.
