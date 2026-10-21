---
name: audit-skill-repos
description: Use when checking whether the upstream skill repos tracked in chezmoi's home/.chezmoidata/skills.yaml (mattpocock/skills, vercel-labs/skills, awesome-copilot, etc.) have gained, renamed, or removed skills that should be reconciled — e.g. "check matt pocock's repo for new skills", "did any tracked skill repos update", "audit skills.yaml against upstream".
---

# Audit Skill Repos

Adapted from Drewtopia/dotfiles. Diff every upstream skill repo listed in chezmoi's `skills.yaml` against what's tracked, surface new / renamed / removed skills, and — on approval — reconcile `skills.yaml`.

This skill is chezmoi-managed (source: `home/dot_claude/skills/audit-skill-repos/`). Edit the source, then `chezmoi apply` — a target-only edit gets reverted on the next apply.

## Key files

`~/.local/share/chezmoi/home/.chezmoidata/skills.yaml` — source of truth. Each entry: a GitHub `repo:` plus the `skills:` list to install. `run_onchange_after_60-install-skills.sh.tmpl` runs `npx skills add` when the file changes. Nothing runs `npx skills update` automatically.

`~/.local/share/chezmoi/home/.chezmoidata/claude.toml` — plugin marketplaces. Skills delivered by a plugin are enumerated by that plugin's own `.claude-plugin/plugin.json`, so they need no per-name tracking in `skills.yaml`.

## Workflow

1. **Read** `skills.yaml`. For each `repo:`, note the tracked `skills:` names and any category comments.

2. **List upstream skills per repo** — layout-agnostic. A skill = the parent dir of a `SKILL.md`:
   ```bash
   gh api "repos/<owner>/<repo>/git/trees/HEAD?recursive=1" \
     --jq '.tree[] | select(.path|endswith("SKILL.md")) | .path' \
     | sed -E 's#^skills/##; s#/SKILL.md$##' | sort
   ```
   The leaf name (after the last `/`) is the installable skill name; the prefix is its category dir (`engineering/`, `misc/`, `in-progress/`, …).

3. **Diff** upstream leaf-names vs tracked names. Classify:
   - **New** — upstream, not tracked.
   - **Removed / renamed** — tracked, not upstream. A rename shows as one removal + one addition (e.g. `to-prd`→`to-spec`, `diagnose`→`diagnosing-bugs`). Read commit messages to confirm: `gh api "repos/<owner>/<repo>/commits?per_page=10" --jq '.[].commit.message'`.

4. **Triage new skills.** Fetch each candidate's description:
   ```bash
   gh api "repos/<owner>/<repo>/contents/skills/<dir>/SKILL.md" \
     --jq '.content' | base64 -d | awk '/^description:/{sub(/^description: */,"");print;exit}'
   ```
   Flag fit: repo-agnostic + generally useful = strong; course/JS/personal-specific = weak. Note which category dir it lives in (see Gotchas).

5. **Present** a table (New / Renamed / Removed) with fit notes, then **AskUserQuestion** (multiSelect) for which to add, rename or drop. Recommend, don't auto-add.

6. **On approval, edit `skills.yaml`:**
   - Add chosen names under the matching category comment (`# engineering/`, `# misc/`, …).
   - For a rename or removal, also clean up the old install (see Gotchas).
   - Don't add running skill counts to comments — they go stale on every edit.

7. **Verify install** (optional but preferred):
   ```bash
   cd "$HOME" && npx -y skills add <owner>/<repo> -g -y --skill <name…>
   ```
   Confirm `~/.claude/skills/<name>/SKILL.md` exists after. See PromptScript gotcha.

## Gotchas

- **Install layout:** the payload lands in `~/.agents/skills/<name>` and `~/.claude/skills/<name>` is a symlink to it.
- **Hidden category dirs** (`misc/`, `in-progress/`, `personal/`, `deprecated/`) are excluded from `npx skills add <repo> -l` BUT install fine by name via `--skill`. Flag `in-progress/` as unstable — upstream renames and breaks them.
- **`personal/` and `deprecated/`** — don't propose these unless asked.
- **PromptScript "failure" is cosmetic.** Command-style skills (`disable-model-invocation: true`) can print `✗ … PromptScript does not support global skill installation` under a "Failed to install N" banner, yet the install succeeds. Verify on disk, don't trust the exit banner.
- **Removing or renaming a skill** leaves the old payload behind on every machine: dropping it from `skills.yaml` doesn't uninstall it. Remove `~/.claude/skills/<name>` and `~/.agents/skills/<name>` (or `npx skills remove -g <name>`) on each machine, or add both paths to a `home/.chezmoiremove` file so `chezmoi apply` sweeps them.
- **Lock file orphans.** The skills CLI tracks installs in `~/.local/state/skills/.skill-lock.json`. Deleting dirs by hand never touches the lock, so `skills update -g` warns "appear to have been deleted upstream" forever. Fix: back up the lock, then remove the stale names from its `skills` object with jq.
- **Prefer the plugin path when a repo offers one.** A `.claude-plugin/marketplace.json` upstream means the repo can be registered in `claude.toml` instead, which removes per-name reconciliation (upstream's `plugin.json` becomes the list). Costs: skills invoke namespaced (`<plugin>:<skill>`), and you can't cherry-pick.
- **Don't commit unless asked.** Leave the git commit to the user.

## Quick reference

| Need | Command |
|---|---|
| List a repo's skills | `gh api "repos/O/R/git/trees/HEAD?recursive=1" --jq '.tree[]\|select(.path\|endswith("SKILL.md")).path'` |
| One skill's description | `gh api "repos/O/R/contents/skills/DIR/SKILL.md" --jq .content \| base64 -d` |
| Recent commits (rename detection) | `gh api "repos/O/R/commits?per_page=10" --jq '.[].commit.message'` |
| Install by name | `cd ~ && npx -y skills add O/R -g -y --skill NAME…` |
