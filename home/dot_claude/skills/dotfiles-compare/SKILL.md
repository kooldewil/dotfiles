---
name: dotfiles-compare
description: Compare your local chezmoi dotfiles against another person's dotfiles repo on GitHub, fetching the latest changes fresh from GitHub every time. Use this skill whenever the user wants to compare their dotfiles with someone else's, see what tools or configs another person has that they don't, diff their setup against another GitHub user's, find things worth stealing from another dotfiles repo, or get a structured summary of differences between two setups. Trigger on phrases like "compare my dotfiles with X", "look at X's dotfiles", "what does X have that I don't", "diff my setup with X's", "what can I steal from X's dotfiles", "check out [github-url]/dotfiles".
---

# Dotfiles Compare

Compare your local chezmoi-managed dotfiles against a GitHub dotfiles repository, always fetching fresh from GitHub.

## Input

The user will provide one of:
- A GitHub URL (e.g. `https://github.com/Drewtopia/dotfiles`)
- A GitHub username (assume repo name is `dotfiles`)
- A username/repo pair (e.g. `holman/dotfiles`)
- A first name or nickname — resolve using the known contacts list below

Extract the owner and repo name from whatever form they give.

### Known contacts

| Name | GitHub owner | Repo |
|------|-------------|------|
| Drew | Drewtopia | dotfiles |

If the user says "Drew" or "Drew's dotfiles" without providing a URL or username, use `Drewtopia/dotfiles`.

## Step 1: Find local chezmoi root

Run `chezmoi source-path` to get the source directory. If the command fails or isn't available, fall back to `~/.local/share/chezmoi`. This is where your dotfiles live.

## Step 2: Run two surveys in parallel

Spawn two subagents at the same time — one for the remote repo, one for the local files. Don't wait for one before starting the other.

---

### Subagent A: Fetch remote dotfiles (always fresh — no cache)

Your job is to map the full contents of a GitHub dotfiles repo. Fetch everything fresh; do not rely on anything from a previous session.

**Step A1 — Get the file tree**

Fetch `https://github.com/<owner>/<repo>` to get the top-level file listing. Look for:
- A `.chezmoiroot` file — if present, fetch it to find the source subdirectory (e.g. `home/`). All paths then start from that subdirectory.
- The overall directory structure

If the repo uses a subdirectory root (e.g. `home/`), all subsequent paths should be relative to that.

**Step A2 — Fetch config file contents**

For each config file, fetch the raw content from:
`https://raw.githubusercontent.com/<owner>/<repo>/main/<path>`

If you get a 404, try `master` instead of `main`.

Prioritize these files (fetch all you can find):
- `Brewfile` or brew install script
- Shell: `dot_zshrc`, `dot_zshenv`, `dot_zprofile` (chezmoi names) or `.zshrc`, `.zshenv`, `.zprofile`
- Shell modules under `dot_config/shell/` — fetch each numbered file
- `dot_config/shell-loader.sh`
- Git: `dot_gitconfig` or `dot_config/git/config`
- `dot_config/tmux/tmux.conf`
- `dot_config/nvim/` — `init.lua`, `lazyvim.json`, any plugin files under `lua/plugins/`
- `dot_config/ghostty/config`
- `dot_config/aerospace/aerospace.toml`
- `dot_config/kanata/` — all `.kbd` files
- `dot_config/mise/config.toml`
- `dot_config/atuin/config.toml`
- `dot_config/jj/config.toml`
- `dot_config/leaderkey/config.json`
- `dot_claude/CLAUDE.md`, `dot_claude/settings.json`, `dot_claude/mcp.json`
- Any chezmoi scripts under `.chezmoiscripts/`
- `dot_p10k.zsh`

For long files (>150 lines), summarize the key sections rather than returning the full content.

**Return:**
- Full directory tree of the repo
- Contents or meaningful summaries of every config file found
- Note which branch was used (main vs master)

---

### Subagent B: Survey local dotfiles

Your job is to map the full contents of the local chezmoi source directory.

Run `chezmoi source-path` to find the source dir, or fall back to `~/.local/share/chezmoi`.

List all files recursively (skip `.git`). For each config file found, read its contents. Follow the same priority list as Subagent A. For long files (>150 lines), summarize the key sections.

**Return:**
- Full directory tree
- Contents or meaningful summaries of every config file found

---

## Step 3: Synthesize the comparison

Once both subagents complete, generate a comparison document.

### Structure

**Section 1: Tools/configs they have that you don't**

Group by category. For each item:
- Tool name
- One-line description of what it does
- Where it's configured in their repo

Categories to use (only include non-empty ones):
- Dev tooling (VCS, diff tools, language tooling)
- Terminal & shell
- Editor
- Window management
- Claude Code / AI tooling
- Apps (GUI)
- Keyboard & input
- Secrets & auth
- Automation (chezmoi scripts)

**Section 2: Tools/configs you have that they don't**

Same structure.

**Section 3: Structural differences**

A markdown table comparing key architectural choices:

| Area | You | Them |
|------|-----|------|
| Shell framework | ... | ... |
| Terminal | ... | ... |
| Primary VCS | ... | ... |
| Git config location | ... | ... |
| Cross-platform | ... | ... |
| Secret management | ... | ... |
| Commit signing | ... | ... |
| Chezmoi scripts | ... | ... |
| Leaderkey / launcher | ... | ... |

**Section 4: Suggested adoptions**

The 5 most impactful things worth adopting from their setup, ranked. For each: what it is and a one-sentence rationale.

### Output

1. Write the comparison to `COMPARISON-<github-username>.md` in the user's chezmoi root (the path from `chezmoi source-path`).
2. In the conversation, give a short summary: the 3 biggest differences and where the file was written.
