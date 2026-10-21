---
name: find-session
description: Search past Claude sessions by a fuzzy memory of what they were about; ranked results with resume commands.
disable-model-invocation: true
---

# Find session

Adapted from Drewtopia/dotfiles. No native content-search exists — `claude --resume` is a picker
with no query — so this greps the transcripts directly.

## Run

1. Turn the user's fuzzy memory into search terms — synonyms, likely file/API/function names, error
   strings. More specific terms rank better; start narrow, broaden if empty.
2. `uv run ~/.claude/skills/find-session/find-session.py <terms...>`
   Add `--all` to search every project; default scope is the **current project's** slugs (derived
   from cwd), **including its worktree slugs** (`*--claude-worktrees-*`).
3. The script rg's transcripts, ranks by distinct terms matched, then hit count, then recency, and
   prints date · title · branch · snippet · `claude --resume <id>`.
4. Present the top hits. If none fit, expand or swap terms and re-run. Offer to resume the pick.

## Notes

- Sessions started in another directory (e.g. `~` vs the chezmoi source) live under a different
  project slug — use `--all` when the user isn't sure where they were.
- Search covers both the user's prompts and the assistant's replies.
- Keyword/regex only — no embeddings. If recall keeps missing, broaden terms rather than reach for
  semantic search.
- Transcripts older than `cleanupPeriodDays` (90 here) are deleted and can't be found.
- The transcript JSONL format is internal and changes between Claude Code releases — if results go
  empty or fields vanish after an upgrade, suspect the format before the search terms.
