# External Tool References

This directory stores curated LLM context files for external tools and libraries.

## Pattern

Name files `{tool-or-library}-llms.txt` containing:
- Official docs summaries
- Common patterns and APIs
- Troubleshooting tips
- Links to full docs

## Examples

- `uv-llms.txt` — Python package manager
- `nixpacks-llms.txt` — Language detection & build tool
- `design-system-reference-llms.txt` — Design system components & tokens

When an agent needs to work with a specific tool, it reads the relevant file to ground its knowledge in actual APIs/conventions instead of relying solely on training data.

## Refreshing References

Keep these up-to-date with tool releases:

```bash
# Fetch latest docs for tool X
# summarize to {tool}-llms.txt
```
