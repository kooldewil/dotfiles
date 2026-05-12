# Dotfiles Comparison: Shaunak vs Drewtopia

_Generated: 2026-05-12_

---

## Section 1: Tools/configs Drew has that you don't

### Dev Tooling (VCS, diff tools, language tooling)

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **jj (Jujutsu)** | Modern VCS layered on top of git — better conflict handling, first-class revsets, no staging area | `dot_config/jj/config.toml.tmpl` |
| **delta** | Syntax-highlighted, side-by-side git diff pager | `dot_config/git/config.tmpl` (`[pager]` + `[delta]`) |
| **LazyGit** | TUI git client | `dot_config/lazygit/` |
| **Commit signing** | SSH Ed25519 key signing for personal commits | `dot_config/git/config.tmpl` (`[commit] gpgSign = true`) |
| **1Password CLI** | Secrets from vault in chezmoi templates (name, email, API tokens) | `home/.chezmoi.toml.tmpl`, `dot_zshenv.tmpl` |

### Terminal & Shell

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **Ghostty** | GPU-accelerated terminal (faster than Terminal.app) | `dot_config/ghostty/config` |
| **Tmux** | Terminal multiplexer with catppuccin theme, session resurrection, floating panes | `dot_config/tmux/tmux.conf` |
| **Television** | Context-aware fuzzy finder for history/files/channels; replaces atuin's Ctrl+R | `dot_config/shell/020-shell-tools.sh.tmpl` |
| **Carapace** | Universal shell completion engine with bridge support | `dot_config/shell/020-shell-tools.sh.tmpl` |
| **pay-respects** | Rust-based command correction (thefuck alternative) | `dot_config/shell/030-system-tools.sh.tmpl` |
| **Navi / cheatsheets** | Interactive cheatsheet system with fzf, bound to Ctrl+\ | `dot_config/shell/040-cheatsheets.sh.tmpl` |
| **fnox** | Shell-integrated secrets manager | `dot_config/shell/020-shell-tools.sh.tmpl` |
| **topgrade** | All-in-one system updater (brew, mise, npm globals, etc.) | `dot_config/topgrade.toml` |
| **atuin (enhanced)** | Drew's config adds: secrets regex filtering (AWS keys, GitHub tokens), daemon mode, workspace filtering | `dot_config/atuin/config.toml.tmpl` |

### Editor

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **Neovim + LazyVim** | Full Neovim setup with 37 extras: Claude Code, Copilot, debugging, testing, 10+ language servers | `dot_config/nvim/` (`init.lua`, `lazyvim.json`, `lua/plugins/`) |
| **hardtime.nvim** | Forces hjkl navigation by disabling arrow keys — builds muscle memory | `dot_config/nvim/lua/plugins/hardtime.lua` |
| **chezmoi.nvim** | Edit chezmoi source files directly from Neovim with live preview | `dot_config/nvim/lua/plugins/chezmoi.lua` |

### Window Management

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **AeroSpace** | Tiling window manager with named workspaces (B/D/M/N/O/S/T/W), app auto-assignment, vim-like navigation | `dot_config/aerospace/aerospace.toml` |
| **JankyBorders** | Active window border highlighting (works with AeroSpace) | `dot_config/aerospace/aerospace.toml` (auto-started) |
| **jordanbaird-ice** | Menubar icon manager / hider | Brewfile (cask) |
| **Lunar** | Monitor brightness and color management | Brewfile (cask) |
| **BetterDisplay** | Advanced display resolution and brightness control | Brewfile (cask) |

### Claude Code / AI Tooling

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **CLAUDE.md tracked in chezmoi** | Global Claude instructions (VCS preference, memory system, security rules) sync'd across machines | `dot_claude/CLAUDE.md.tmpl` |
| **Claude settings + hooks** | Pre-tool secret blocking, dangerous command filter, session startup checks, jj VCS integration | `dot_claude/settings.json.tmpl` |
| **Memory push/pull hooks** | Auto-commits and pushes `~/.claude/memory` git repo; pulls on session start | `dot_claude/hooks/memory-push.sh`, `memory-pull.sh` |
| **jj-describe hook** | PreToolUse: auto-updates jj working revision description with each file Claude edits | `dot_claude/hooks/jj-describe-claude.sh` |
| **session-start-git-status** | SessionStart hook: warns if branch >3 days old, 20+ commits ahead, stale worktrees | `dot_claude/hooks/session-start-git-status.sh` |
| **jj-block-trunk hook** | Prevents commits directly to trunk | `dot_claude/hooks/jj-block-trunk.sh` |
| **Custom commands** | `/close` (end session, capture thoughts, write SESSION_LOG), `/vault-sync` (sync memory vault) | `dot_claude/commands/` |
| **Skills framework** | Skills installed from 6 marketplaces (caveman, claude-brain-sync, karpathy-skills, etc.) | `.chezmoidata/claude.toml`, `dot_claude/skills/` |
| **MCP servers** | Home Assistant MCP, Obsidian MCP, sequential-thinking | `dot_claude/mcp.json.tmpl` |
| **ccstatusline** | Claude Code status line (tracked and configured in chezmoi) | `dot_config/ccstatusline/` |

### Apps (GUI)

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **Hammerspoon** | Lua-scriptable macOS automation | Brewfile (cask) |
| **Hazel** | Automated file organization rules | Brewfile (cask) |
| **SoundSource** | Per-app audio routing and volume control | Brewfile (cask) |
| **Unclack** | Mutes keyboard typing sounds during calls | Brewfile (cask) |
| **Muzzle** | Silences notifications during screen sharing | Brewfile (cask) |
| **Bruno** | Open-source API client (Postman alternative) | Brewfile (cask) |
| **Raindrop.io** | Bookmark manager | Brewfile (cask) |
| **KeyClu** | Shows keyboard shortcuts overlay | Brewfile (cask) |
| **Lookaway** | Screen break reminder | Brewfile (cask) |
| **Orion browser** | WebKit browser with extension support | Brewfile (cask) |
| **Zen browser** | Firefox-based privacy browser | Brewfile (cask) |
| **WezTerm** | GPU terminal emulator (secondary) | Brewfile (cask) |
| **IINA** | Native macOS media player | Brewfile (cask) |
| **ImageOptim** | Image compression tool | Brewfile (cask) |
| **glance-chamburr / Syntax Highlight** | QuickLook plugins for code files | Brewfile (casks) |

### Automation (chezmoi scripts)

| Script | Description |
|--------|-------------|
| `run_before_03-backup-claude-memory` | Backs up `~/.claude/memory` before each chezmoi apply |
| `run_onchange_after_10-install-mise-tools` | Installs all mise-managed tools after config change |
| `run_onchange_after_15-pnpm-globals` | Installs pnpm globals (@openai/codex, @playwright/cli, etc.) |
| `run_onchange_after_20-configure-shell-tools` | Configures atuin, carapace, zoxide completions |
| `run_onchange_after_30-set-git-origin` | Sets git remote origin from constants.toml |
| `run_onchange_after_40-install-claude-code` | Installs/upgrades Claude Code CLI |
| `run_onchange_after_55-update-claude-marketplaces` | Refreshes Claude skill marketplaces |
| `run_onchange_after_60-install-skills` | Installs skills from skills.yaml |
| `run_before_install-brew-packages` | Installs Homebrew packages (darwin) |
| `run_onchange_after_60-configure-dock` | Configures macOS Dock layout via dockutil |

---

## Section 2: Tools/configs you have that Drew doesn't

### Terminal & Shell

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **MacroWhisper** | Voice-to-text macros: `google <phrase>` → Arc, `kagi <phrase>` → Arc search | `dot_config/macrowhisper/macrowhisper.json` |
| **path-management.sh** | Separate PATH manipulation helper with documented priority order | `dot_config/path-management.sh.tmpl` |

### Apps (GUI)

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **BetterTouchTool** | Advanced gesture and shortcut customization for trackpad/mouse | Brewfile (cask) |
| **DaisyDisk** | Visual disk usage analyzer | Brewfile (cask) |
| **AppCleaner** | Complete app removal with leftover file detection | Brewfile (cask) |
| **AdGuard** | System-wide ad/tracker blocking | Brewfile (cask) |
| **Mouseless** | Keyboard-driven mouse cursor control | Brewfile (cask) |
| **DockDoor** | Dock hover window previews (like Windows taskbar) | Brewfile (cask) |
| **Evernote** | Note-taking / web clipper | Brewfile (cask) |
| **Stremio** | Media streaming aggregator | Brewfile (cask) |
| **Calibre** | Ebook management and conversion | Brewfile (cask) |

### MAS Apps (you have, Drew doesn't)

| App | Description |
|-----|-------------|
| **Bear** | Markdown note-taking app |
| **CloudMounter** | Cloud storage as local disk mounts |
| **rcmd** | App switcher via right-Cmd + key |
| **Velja** | Browser picker by URL/source app |
| **Hyperduck** | Send URLs from iPhone to Mac |

---

## Section 3: Structural Differences

| Area | You (Shaunak) | Drew |
|------|--------------|------|
| Shell framework | Oh My Zsh + Zinit + p10k | Oh My Zsh + Zinit + p10k |
| Terminal | Terminal.app | Ghostty |
| Primary VCS | git | jj (on top of git) |
| Git config location | `dot_gitconfig` (home dir) | `dot_config/git/config` (XDG) |
| Git diff pager | Default | delta (side-by-side, syntax-highlighted) |
| Cross-platform | macOS only | macOS + Linux + Windows/WSL |
| Secret management | None tracked | 1Password CLI + fnox |
| Commit signing | Not configured | SSH Ed25519 (personal), auto-signed |
| Chezmoi scripts | 1 (kanata setup) | 20+ (brew, mise, pnpm, Claude, dock, git, skills) |
| Editor | nano (git default) | nvim + LazyVim (37 extras, Claude Code plugin) |
| Neovim config tracked | No | Yes (full LazyVim setup) |
| Window management | Raycast + Rectangle Pro | AeroSpace tiling WM + JankyBorders + Rectangle Pro |
| Claude Code in chezmoi | No | Yes (CLAUDE.md, settings, hooks, commands, skills) |
| Claude hooks | None | 5 hooks (memory sync, jj describe, session start, trunk block) |
| Claude memory | File-based (this repo) | Separate git repo with auto-push/pull |
| MCP servers | Gmail, Calendar, Drive, Todoist | Home Assistant, Obsidian, sequential-thinking |
| Mise tools | node LTS, python 3.12 | node, python, go, rust, zig, neovim, chezmoi + 10 aqua tools |
| Tmux | None | Full config (catppuccin, session resurrection, floating panes) |
| Fuzzy finder | fzf + atuin | fzf + television + atuin |
| Shell completion | zsh native + fzf-tab | zsh native + fzf-tab + carapace |
| Command correction | None | pay-respects (thefuck alternative) |
| Cheatsheets | None | Navi integration, Ctrl+\ bound |
| Voice input | MacroWhisper | None tracked |
| chezmoidata | Not used | `claude.toml`, `constants.toml`, `pnpm-globals.yaml`, `skills.yaml` |

---

## Section 4: Suggested Adoptions (Ranked)

### 1. Track Claude Code in chezmoi (hooks + CLAUDE.md + settings)

Drew's setup auto-syncs a `~/.claude/memory` git repo on every session start/end, auto-updates jj revision descriptions as Claude edits files, blocks dangerous commands, and checks branch staleness at session start. Your Claude config lives outside chezmoi entirely. This is the single highest-leverage adoption — it makes Claude dramatically more useful across machines and over time.

**Key files:** `dot_claude/CLAUDE.md.tmpl`, `dot_claude/settings.json.tmpl`, all 5 hooks in `dot_claude/hooks/`

### 2. Delta git diff pager

One-line change to `.gitconfig` — add `[pager] diff = delta` and configure side-by-side mode. Every `git diff`, `git log -p`, and `git show` becomes dramatically more readable. Delta integrates with bat for syntax highlighting.

**Key file:** `dot_config/git/config.tmpl` `[pager]` + `[delta]` sections

### 3. AeroSpace tiling window manager

Replaces the manual Rectangle Pro window snapping with an i3-inspired tiling WM. Named workspaces (B=Browser, D=Dev, T=Terminal, etc.) with app auto-assignment means your desktop is always organized without thinking. Alt+hjkl to move focus; Alt+Shift+hjkl to move windows. Drew's config is directly adoptable as a starting point.

**Key file:** `dot_config/aerospace/aerospace.toml`

### 4. Jujutsu (jj) VCS

Drew runs jj on top of his existing git repos — it's a drop-in layer, not a migration. No staging area, automatic working-copy commits, first-class undo, and revsets for querying history. The Claude hook that auto-describes jj revisions as Claude edits files is uniquely powerful with jj.

**Key file:** `dot_config/jj/config.toml.tmpl`

### 5. Atuin secrets filtering + daemon mode

A 5-line addition to your existing `atuin/config.toml`: add regex filters to strip AWS keys, GitHub tokens, and `.env` values from history before they're synced. Daemon mode improves startup latency. Since you already use atuin, this is zero friction.

**Key file:** `dot_config/atuin/config.toml.tmpl` — add `secrets_filter`, `daemon.enabled`, `filter_mode`
