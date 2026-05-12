# Dotfiles Comparison: You vs. Drew (Drewtopia)

*Generated: 2026-05-12*

---

## Section 1: Drew has — you don't

### Dev Tooling

| Tool/Config | What it does | Drew's location |
|-------------|-------------|-----------------|
| `bat/config` | Catppuccin Mocha theme, `.tmpl` → Go syntax, `--paging=never` default | `dot_config/bat/config` |
| `ripgrep/config` | Excludes `vendor/`, `node_modules/`, `.git/`; enables `smart-case` globally | `dot_config/ripgrep/config` |
| `fd/ignore` | Global ignore patterns (`.git`, `node_modules`, `vendor`, build artefacts) | `dot_config/fd/ignore` |
| `glow` config | Catppuccin theme for markdown rendering | `dot_config/glow/glow.yml` |
| `topgrade.toml` | Unified system updater config (skips certain steps, sets order) | `dot_config/topgrade.toml` |
| `navi` | Interactive cheatsheet tool with `ctrl+g` binding | `dot_config/navi/config.yaml` + mise entry |
| `btop` | Resource monitor config | `dot_config/btop/btop.conf` |
| `lazygit` config | Empty placeholder (intentional — uses defaults) | `dot_config/lazygit/empty_config.yml` |
| `gh` CLI config | GitHub CLI config with preferred editor, git protocol | `dot_config/gh/` |

### Terminal & Shell

| Tool/Config | What it does | Drew's location |
|-------------|-------------|-----------------|
| `dot_zprofile.tmpl` | **Critical:** re-sources `.zshenv` after macOS `path_helper` scrambles PATH | `dot_zprofile.tmpl` |
| `000-paths.sh.tmpl` | Explicit `$PATH` ordering at shell init | `dot_config/shell/000-paths.sh.tmpl` |
| `030-system-tools.sh.tmpl` | Homebrew init, XDG dirs, system tool setup | `dot_config/shell/030-system-tools.sh.tmpl` |
| `040-cheatsheets.sh.tmpl` | Sources cheatsheet files; `cheat` function for quick reference | `dot_config/shell/040-cheatsheets.sh.tmpl` |
| Cheatsheets | Structured reference: git (298L), shell (341L), tmux (349L), chezmoi (241L) | `dot_config/cheatsheets/` |
| `brew.env.tmpl` | Homebrew env: `HOMEBREW_NO_ANALYTICS`, `HOMEBREW_BUNDLE_FILE` path | `dot_config/homebrew/brew.env.tmpl` |
| `empty_dot_hushlogin` | Suppresses macOS "Last login" message | `dot_hushlogin` |
| `dot_wslconfig.tmpl` | Windows WSL2 memory/CPU limits | `dot_wslconfig.tmpl` |
| PowerShell profile | Windows PowerShell init (oh-my-posh, mise, etc.) | `dot_config/powershell/` |

### Claude Code / AI Tooling

| Tool/Config | What it does | Drew's location |
|-------------|-------------|-----------------|
| `cvault` CLI | Bash script: create/list/sync memory vault entries from CLI | `dot_local/bin/executable_cvault` |
| `symlink_memory.tmpl` | Symlinks `~/.claude/memory` → vault directory for cross-machine sync | `dot_claude/symlink_memory.tmpl` |
| `symlink_rules.tmpl` | Symlinks `~/.claude/rules` → vault directory | `dot_claude/symlink_rules.tmpl` |
| `/close` command | Session close ritual: update memory, commit, push | `dot_claude/commands/close.md` |
| `/vault-sync` command | Sync memory vault to/from GitHub | `dot_claude/commands/vault-sync.md` |
| `ccstatusline` settings | Claude Code status line customization | `dot_config/ccstatusline/settings.json.tmpl` |
| `copilot-instructions.md` | GitHub Copilot system prompt (templated per identity) | `dot_github/copilot-instructions.md.tmpl` |
| Additional skills | `audit-rules-and-skills`, `close`, `reorganize-memory` | `dot_claude/skills/` |
| Additional chezmoidata | `claude.toml` with vault paths, model preferences | `.chezmoidata/claude.toml` |

### Automation (chezmoi scripts)

Drew has a comprehensive bootstrap — you have only 4. His additional scripts:

| Script | What it does |
|--------|-------------|
| `run_onchange_install-pnpm-globals.sh` | Installs pnpm global packages |
| `run_onchange_configure-shell-tools.sh` | Sets default shell, configures atuin, etc. |
| `run_onchange_set-git-origin.sh.tmpl` | Sets git remote to SSH URL |
| `run_once_install-claude-code.sh` | Installs Claude Code CLI |
| `run_once_configure-dock.sh` | macOS Dock layout and settings |
| `.chezmoiexternal.toml.tmpl` | Manages external repos/files (e.g. OMZ plugins) |
| `.chezmoiremove.tmpl` | Removes stale managed files on apply |

### Apps (GUI)

| App/Config | Drew's location |
|-----------|-----------------|
| VS Code MCP configs | `dot_config/Code/` |

---

## Section 2: You have — Drew doesn't

### Tools & Config

| Tool/Config | What it does | Your location |
|-------------|-------------|---------------|
| `macrowhisper` config | AI voice transcription tool config | `dot_config/macrowhisper/macrowhisper.json` |

### Shell Structure

| Item | Notes |
|------|-------|
| `010-history.sh` | Dedicated history config module — Drew inlines this in his main zshrc |
| `020-completion.sh` | Dedicated completion module |
| `070-functions.sh` | Dedicated functions module |
| `dot_config/path-management.sh.tmpl` | **Dead code** — leftover file; safe to remove |

### Claude Code / AI Tooling

| Skill | What it does |
|-------|-------------|
| `dotfiles-compare` | Compares local chezmoi dotfiles against another person's repo |
| `fix-ebooks` | Processes and fixes ebook files |
| `handoff` | Session handoff ritual |

---

## Section 3: Structural Differences

| Area | You | Drew |
|------|-----|------|
| Shell framework | Oh My Zsh (via zinit) | Oh My Zsh (via zinit) |
| Shell module numbering | `010`, `020`, `050`, `060`, `070` | `000`, `030`, `040`, `050`, `060` |
| Terminal | Ghostty | Ghostty |
| Primary VCS | git | git (+ jj) |
| Git config location | `dot_gitconfig.tmpl` | `dot_config/git/config.tmpl` (XDG) |
| Cross-platform | macOS + Windows | macOS + Windows + WSL2 |
| Secret management | 1Password CLI + chezmoi `onepasswordRead` | 1Password CLI + chezmoi `onepasswordRead` |
| Commit signing | SSH (1Password agent) | SSH (1Password agent) |
| macOS PATH fix | **Missing** `dot_zprofile.tmpl` | Has `dot_zprofile.tmpl` re-sourcing `.zshenv` |
| Chezmoi bootstrap scripts | 4 scripts (mise, 1password, claude-marketplaces, skills) | 4 + 7 more (pnpm-globals, configure-shell-tools, set-git-origin, install-claude-code, configure-dock, externals, remove) |
| Memory/vault CLI | None | `cvault` bash CLI |
| Memory symlinks | Manual file-based | Templated symlinks to vault |
| Cheatsheets | None | 4 structured cheatsheets + `cheat` function |
| Leaderkey | Full Rectangle Pro group, Ghostty, custom apps | Lighter set, fewer window management entries |
| kanata | Split 4-file structure | Split 4-file structure |

---

## Section 4: Suggested Adoptions (ranked)

### 1. `dot_zprofile.tmpl` — Fix macOS PATH ordering
**What:** A 5-line template that re-sources `.zshenv` after macOS's `/etc/zprofile` runs `path_helper` and reverses your carefully-ordered PATH.  
**Why:** Without this, any PATH ordering you set in `.zshenv` gets silently overridden in login shells (new terminal windows). This is a subtle bug that causes `which node` and similar to resolve to the wrong binary.  
**Effort:** Trivial — copy Drew's file verbatim.

### 2. `bat/config` + `ripgrep/config` + `fd/ignore`
**What:** Three small config files that tune your most-used CLI tools (you already have all three installed via mise).  
**Why:** `bat` without Catppuccin theming is visually inconsistent with your terminal. `ripgrep` without smart-case and vendor exclusions gives noisy results. `fd/ignore` prevents cluttered output. All three are pure upside.  
**Effort:** Trivial — copy three small files, no template logic needed.

### 3. `cvault` + memory symlink setup
**What:** A bash CLI (`cvault`) for creating/listing/syncing Claude memory vault entries, plus chezmoi symlink templates that wire `~/.claude/memory` and `~/.claude/rules` to a synced vault directory.  
**Why:** Your current memory system is file-based but not synced across machines. This gives you a proper workflow for memory management and makes the vault portable.  
**Effort:** Medium — requires deciding on a vault directory and adapting the symlink paths.

### 4. Chezmoi bootstrap scripts (at minimum: `configure-shell-tools`, `set-git-origin`)
**What:** `run_onchange_*` scripts that make `chezmoi apply` on a new machine fully self-bootstrapping.  
**Why:** Right now setting up a new machine requires manual steps after `chezmoi apply`. These two scripts cover the 80% case: default shell is set and git remotes use SSH.  
**Effort:** Medium — scripts need path adaptation, but the logic is reusable as-is.

### 5. Cheatsheets system (`040-cheatsheets.sh.tmpl` + cheatsheets directory)
**What:** Four structured markdown cheatsheets (git, shell, tmux, chezmoi) accessible via a `cheat <topic>` shell function using `glow` for rendering.  
**Why:** You already have `glow` installed via mise. The cheatsheets represent curated muscle-memory references faster than man pages and tailored to your workflow. The `cheat` function makes them 2 keystrokes away.  
**Effort:** Low — copy files and shell module; cheatsheets can be adopted verbatim or customized over time.
