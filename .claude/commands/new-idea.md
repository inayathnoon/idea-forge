# /new-idea — Full Pipeline from Scratch

Run the complete idea pipeline from raw idea to GitHub repo.

## Process

### 1. Start Fresh
Check `memory/ideas_store.json` exists (create if not). This is a new idea — start at stage `raw`.

### 2. Run Pipeline
Run each agent in sequence using the `/advance` flow (checkpoint → agent → cross-cutting → feedback):

1. **idea-capturer-1** — Capture and structure the raw idea
2. **idea-explorer-2** — Explore 10 directions, pick top 3, user selects
3. **strategist-3** — Stress-test, generate agent persona, issue verdict

**Gate**: If verdict is `approved`, continue. If `revise`, loop back to stage 1. If `reject`, stop.

4. **researcher-4** — Market research, competitors, validation
5. **prd-writer-5** — Write the PRD
6. **arch-writer-6** — Design the architecture
7. **plan-writer-7** — Create the build plan
8. **project-manager** — Final decision docs
9. **doc-pusher-8** — Create GitHub repo, push everything

### 3. For Each Stage
Follow the `/advance` command process:
- Auto-checkpoint before each agent
- Run the agent (follow its `.md` file exactly)
- Trigger cross-cutting agents (project-manager after stages 1-3 and 7-8)
- Collect feedback

### 4. Done
When doc-pusher completes, the generated repo is self-contained. Show the final report from doc-pusher.
