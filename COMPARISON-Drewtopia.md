# Dotfiles Comparison: You vs Drewtopia

Generated: 2026-05-12

---

## Section 1: Tools/Configs Drew Has That You Don't

### Dev Tooling

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **jj (Jujutsu)** | Git-compatible VCS with better branch model, rich aliases, SSH signing | `dot_config/jj/config.toml.tmpl` |
| **lazygit** | Terminal UI for git | `mise/config.toml.tmpl` (aqua backend) |
| **delta** | Syntax-highlighted git diffs and pager | `mise/config.toml.tmpl`; wired as jj pager |
| **carapace** | Universal shell completion engine (replaces zsh-completions) | `shell/020-shell-tools.sh.tmpl` |
| **television** (tv) | Context-aware fuzzy finder (Ctrl+T) with channels for atuin, git, chezmoi, dirs, obsidian | `dot_config/television/`; wired in `020-shell-tools` |
| **pay-respects** | Rust `thefuck` replacement — corrects last command via `f` alias | `shell/030-system-tools.sh.tmpl` |
| **fnox** | Secrets manager with shell integration | `shell/020-shell-tools.sh.tmpl` |
| **gitleaks** | Secrets scanner | `mise/config.toml.tmpl` |
| **biome** | JS/TS formatter + linter (all-in-one) | `mise/config.toml.tmpl` |
| **zig** | Used as `CC` for nvim-treesitter parser compilation | `mise/config.toml.tmpl` |
| **tokei** | Fast code statistics (lines, files, etc.) | `mise/config.toml.tmpl` |
| **jless** | JSON/YAML TUI viewer | `mise/config.toml.tmpl` (unix only) |
| **qmd** | Local markdown search engine (BM25 + vector + LLM rerank) | `mise/config.toml.tmpl`; Claude plugin `qmd@qmd` |
| **gdu** | Fast disk usage analyzer (TUI) | `mise/config.toml.tmpl` |
| **pnpm globals** | Managed set of pnpm packages installed on every machine | `.chezmoidata/pnpm-globals.yaml` + script |
| **Aqua backend for mise** | Checksum-verified tool installs (bat, fd, rg, delta, lazygit, jj, gh…) | `mise/config.toml.tmpl` |

### Terminal & Shell

| Tool/Pattern | Description | Where configured |
|------|-------------|-----------------|
| **zsh-active-cheatsheet** | Inline cheatsheet browser bound to `^\` (ctrl+backslash) | `shell/040-cheatsheets.sh.tmpl`; cheatsheets at `dot_config/cheatsheets/` |
| **Compiled cheatsheets** | Cheats for chezmoi, git, shell, tmux — browsable via fzf | `dot_config/cheatsheets/{chezmoi,git,shell,tmux}/` |
| **navi** | Interactive cheatsheet runner | `dot_config/navi/config.yaml` |
| **Shell module 025-tmux.sh** | Rich tmux helpers: `t`, `ta`, `th`, `tp`, `tl`, `tk`, `tq`, `tka`, `tmuxkeys`, `tmuxflow`, `thelp` | `shell/025-tmux.sh.tmpl` |
| **Richer eza aliases** | `l`, `ll`, `llm`, `la`, `lx`, `lt`, `llt`, `ltt` variants | `shell/050-common-aliases.sh.tmpl` |
| **No zsh-autosuggestions** | Removed as redundant with atuin + fzf-tab (cleaner startup) | (intentionally absent) |
| **atuin up-arrow binding** | Up-arrow also triggers atuin history (not just Ctrl+R) | `shell/020-shell-tools.sh.tmpl` |
| **television cable channels** | Custom tv channels for atuin-history, chezmoi, dirs, dotfiles, mise-tools, obsidian-notes, pnpm-packages, recent-files, todo-comments | `dot_config/television/cable/` |

### Tmux (full plugin stack)

| Plugin | Purpose |
|--------|---------|
| **tmux-sessionx** | Session picker with preview (prefix+o) |
| **tmux-floax** | Floating terminal popup (prefix+p) |
| **tmux-thumbs** | Quick visual copy without entering copy mode (prefix+Space) |
| **tmux-fzf-url** | Pick and open URLs from scrollback (prefix+u) |
| **tmux-resurrect** + **tmux-continuum** | Persist and auto-restore sessions across reboots |
| **catppuccin-tmux** | Status bar theme |
| **tmux-yank** | Clipboard integration |

Drew's tmux prefix is `^A`, with vim-tmux-navigator for pane navigation.

### Editor (Neovim/LazyVim)

Drew has a full LazyVim Neovim config you don't have at all:
- `dot_config/nvim/` with `init.lua`, `lazyvim.json`, `lazy-lock.json`
- Custom plugins: `chezmoi.lua`, `catppuccin.lua`, `hardtime.lua` (bad habits enforcer), `snacks.lua`, `surround.lua`, `tmux.lua`
- Neovim installed via mise (always latest, upgrades cleanly)

### Window Management

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **AeroSpace** | Tiling window manager (i3-style) with named workspaces B/D/M/N/T/W | `dot_config/aerospace/aerospace.toml` |
| **JankyBorders** | Window border highlighting for active/inactive windows | Called from AeroSpace `after-startup-command` |

### Claude Code / AI Tooling

Drew's settings.json has significantly more:

**More allowed tools:** `jj`, `pnpm run`, `docker`, `kubectl`, `terraform`, `delta`, `zoxide`, `duf`, `htop`, `btop`, `hexyl`

**More hooks:**
- `block-secrets.py` — pre-Read/Edit/Write secrets scanner
- `block-dangerous-commands.sh` — pre-Bash safety check
- `after-edit.sh` — PostToolUse on file edits
- `end-of-turn.sh` — Stop hook
- `notify.sh` — Notification hook
- `jj-block-trunk.sh` — blocks edits on jj trunk
- `jj-describe-claude.sh` — auto-describes jj commits
- Auto-fix permissions on SessionStart

**More enabled plugins:** `caveman`, `obsidian`, `qmd`, `code-review`, `feature-dev`, `typescript-lsp`, `commit-commands`, `playwright`, `code-simplifier`, `plugin-dev`, `explanatory-output-style`, `learning-output-style`, `hookify`, `superpowers`, `context7`

**Custom slash commands:** `vault-sync.md`, `close.md`

**MCP servers:** `ha-mcp` (Home Assistant), `mcp-obsidian`

**Skills:** `audit-rules-and-skills`, `reorganize-memory`, `close`

**Memory system:** `symlink_memory.tmpl` + `symlink_rules.tmpl` — memory and rules as chezmoi symlinks

**CCStatusLine:** `bun x -y ccstatusline@latest` (vs your custom bash script)

### Apps (Drew has, you don't)

| App | Category | Purpose |
|-----|----------|---------|
| iina | Media | macOS-native video player |
| Hammerspoon | Automation | Lua-based macOS automation |
| Hazel | Automation | File rule automation |
| jordanbaird-ice | Menu bar | Menu bar item hider |
| JDownloader | Utilities | Download manager |
| Muzzle | Utilities | Silences notifications during screen share |
| Unclack | Utilities | Mutes keyboard mic while typing |
| Onyx | Utilities | macOS maintenance tool |
| Orion | Browser | WebKit browser with extension support |
| SoundSource | Audio | Per-app audio routing |
| glance-chamburr | Quick Look | Quick Look for many file types |
| syntax-highlight | Quick Look | Syntax highlighting in Quick Look |
| Fmail3 | Email | Native Gmail client |
| Jump Desktop Connect | Remote | Remote desktop server |
| KeyCastr | Input | Shows keystrokes on screen |

### Secrets & Auth

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **fnox** | Shell-integrated secrets manager | `shell/020-shell-tools.sh.tmpl` |
| **Backup + junction for claude memory** | `run_before_03-backup-claude-memory` + `run_after_99-claude-memory-junction` | `.chezmoiscripts/common/` |

### Automation (Chezmoi Scripts)

Scripts Drew has that you don't:

| Script | Purpose |
|--------|---------|
| `run_before_03-backup-claude-memory` | Backs up claude memory before apply |
| `run_before_05-update-tv-channels` | Updates television cable channels |
| `run_after_50-fix-claude-plugin-permissions` | Fixes Claude plugin file permissions |
| `run_after_99-claude-memory-junction` | Creates junction/symlink for claude memory |
| `run_onchange_after_15-pnpm-globals` | Installs pnpm global packages from pnpm-globals.yaml |
| `run_onchange_after_30-set-git-origin` | Sets git remote origin |
| `run_onchange_after_40-install-claude-code` | Installs Claude Code CLI |
| `run_onchange_after_55-update-claude-marketplaces` | Updates Claude plugin marketplaces |
| `run_onchange_after_60-install-skills` | Installs skills from skills.yaml |
| `run_onchange_before_00-install-mise` | Installs mise before everything else |
| `run_onchange_after_50-setup-kanata` | Sets up kanata daemon |
| `run_onchange_after_60-configure-dock` | Configures macOS Dock layout |

Drew also has `.chezmoitemplates/` with reusable template functions (`path-functions`, `shell-config-functions`, `tool-functions`) and `.chezmoidata/` with structured data files.

### Other Configs

- `dot_config/bat/config` — bat pager config
- `dot_config/btop/btop.conf` — system monitor config
- `dot_config/glow/glow.yml` — markdown reader config
- `dot_config/ripgrep/config` — rg defaults
- `dot_config/fd/ignore` — fd ignore rules
- `dot_config/topgrade.toml` — upgrade tool config
- `dot_config/homebrew/brew.env.tmpl` — Homebrew env settings
- `dot_github/copilot-instructions.md.tmpl` — GitHub Copilot instructions
- `dot_local/bin/cvault` — custom vault script
- `dot_ssh/` — full SSH config with 1Password agent keys

---

## Section 2: Tools/Configs You Have That Drew Doesn't

### Dev Tooling

| Tool | Description | Where configured |
|------|-------------|-----------------|
| **Separate path management** | `path-management.sh` + `paths/` subdir (default/custom/priority) | `dot_config/path-management.sh.tmpl` + `dot_config/shell/paths/` |

### Terminal & Shell

| Tool/Pattern | Description |
|------|-------------|
| **zsh-autosuggestions** | Fish-style autosuggestions (Drew removed this) |
| **Shell module 010-history.sh** | History settings as standalone module |
| **Shell module 020-completion.sh** | Completion config separate from tools |
| **Shell module 070-functions.sh** | Standalone functions file |
| **Separate paths/ directory** | `default.paths.sh`, `custom.paths.sh`, `priority.paths.sh` — granular PATH management |

### Claude Code

| Item | Description |
|------|-------------|
| **skill-creator plugin** | `skill-creator@claude-plugins-official` |
| **brew allowed** | `Bash(brew :*)` in permissions |
| **chezmoi allowed** | `Bash(chezmoi :*)` in permissions |
| **mise allowed** | `Bash(mise :*)` in permissions |
| **WebFetch for GitHub** | `WebFetch(domain:raw.githubusercontent.com)` and `WebFetch(domain:github.com)` |

### Apps (You have, Drew doesn't)

| App | Category |
|-----|----------|
| BetterTouchTool | Automation/gestures |
| Homerow | Keyboard-driven clicks |
| AirBuddy | AirPods companion |
| Alt-tab | Window switcher |
| Linearmouse | Mouse customization |
| DaisyDisk | Disk analyzer |
| AppCleaner | App uninstaller |
| AdGuard | Ad blocker |
| MacWhisper + MacroWhisper | Transcription (you have both) |
| Mouseless | Keyboard-driven mouse |
| DockDoor | Window previews on Dock hover |
| Day One | Journaling |
| Perplexity | AI search |
| Bloom | Music player |
| Calibre | Ebook manager |
| XMind | Mind mapping |
| Stremio | Media streaming |
| Background Music | Per-app audio |
| Fliqlo | Flip clock screensaver |
| Logitech G Hub | Logitech peripherals |
| AltServer | iOS sideloading |

### Skills

| Skill | Purpose |
|-------|---------|
| **fix-ebooks** | Custom ebook fixing scripts |
| **handoff** | Compact conversation handoffs |

---

## Section 3: Structural Differences

| Area | You | Drew |
|------|-----|------|
| **Shell framework** | Oh My Zsh + Zinit (loaded after OMZ) | Oh My Zsh + Zinit (loaded before OMZ; OMZ just for compinit) |
| **Shell plugins** | git (omz), fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting | fzf-tab, zsh-syntax-highlighting only |
| **Completions** | fzf-tab | fzf-tab + carapace (bridges zsh/fish/bash/inshellisense) |
| **Fuzzy finder** | fzf only | fzf (backend) + television (UI, Ctrl+T) with channels |
| **History** | atuin (Ctrl+R) | atuin (Ctrl+R + up-arrow) |
| **Primary VCS** | git only | git + jj (Jujutsu) |
| **Git diffs** | Basic | delta as pager/diff formatter everywhere |
| **Git config location** | `~/.gitconfig` (top-level tmpl) | `~/.config/git/config` (XDG) |
| **Terminal** | Not in dotfiles | Ghostty (managed) + iTerm2 (cask) |
| **Editor** | nvim (brew) | nvim via mise (LazyVim full config) |
| **Window manager** | Rectangle Pro | AeroSpace (tiling) + Rectangle Pro + JankyBorders |
| **Tmux** | Not in dotfiles | Full TPM stack (sessionx, floax, catppuccin, resurrect, thumbs) |
| **Secret management** | 1Password only | 1Password + fnox shell integration |
| **Commit signing** | Not configured | SSH signing via jj (personal machines) |
| **Chezmoi scripts** | 5 scripts | 15+ scripts across common/darwin/linux/windows |
| **Chezmoi templates** | None | `path-functions`, `shell-config-functions`, `tool-functions` |
| **Cross-platform** | macOS only | macOS + Linux (WSL2) + Windows |
| **Leaderkey `t`** | Opens Terminal.app | Opens Ghostty |
| **Leaderkey window mgmt** | Via Raycast extensions | Via Rectangle Pro URL scheme (no Raycast dependency) |
| **Memory system** | MEMORY.md index + topic files | Same + symlinked via chezmoi templates |
| **Claude plugin count** | 1 (skill-creator) | 15+ across dev/personal/common |
| **CCStatusLine** | Custom bash script | `bun x -y ccstatusline@latest` |

---

## Section 4: Suggested Adoptions (Ranked by Impact)

### 1. **television** (tv) — context-aware fuzzy finder

Replace raw fzf Ctrl+T with `television`, which picks the right channel based on context (e.g., `git checkout` → branch picker, `cd` → directory picker). Drew's cable channels add atuin-history, chezmoi files, obsidian notes, mise tools, and recent files. Zero muscle-memory change, immediate productivity win.

**What to add:** `"aqua:alexpasmantier/television" = "latest"` in mise; copy `dot_config/television/` and `dot_config/television/cable/`; add `eval "$(tv init zsh)"` to `shell/020-shell-tools.sh`

### 2. **tmux plugin stack** (sessionx + floax + resurrect)

`tmux-sessionx` (prefix+o) turns tmux into a project switcher with live previews. `tmux-floax` (prefix+p) gives a floating scratchpad without losing context. `tmux-resurrect` + `tmux-continuum` persist sessions across reboots. Drew's `025-tmux.sh` shell helpers make all of this approachable.

**What to add:** Copy `dot_config/tmux/tmux.conf` + `tmux.reset.conf`; copy `shell/025-tmux.sh.tmpl`

### 3. **jj (Jujutsu)** — better VCS workflow

Works alongside git (no migration). Key wins: operation log + `op undo` (undo anything including bad rebases), `wip()` revset (private commits that never push accidentally), `tug` alias for moving bookmarks. Drew's config is mature with delta diffs, SSH signing, and a full alias set.

**What to add:** `dot_config/jj/config.toml.tmpl`; `"aqua:jj-vcs/jj" = "latest"` in mise

### 4. **Richer Claude Code hooks + plugins**

Drew's hooks block dangerous commands pre-Bash, scan for secrets pre-edit, run cleanup on Stop, and send notifications. The plugins he enables (code-review, feature-dev, typescript-lsp, playwright, commit-commands, context7, superpowers) add concrete workflows for daily dev. Low friction to adopt — just update `settings.json.tmpl`.

**What to add:** Expand permissions + hooks in `dot_claude/settings.json.tmpl`; update `enabledPlugins`; copy `hooks/block-secrets.py`, `hooks/block-dangerous-commands.sh`, `hooks/end-of-turn.sh`, `hooks/notify.sh`

### 5. **Chezmoi install scripts** (install-claude-code + pnpm-globals + configure-shell-tools)

`run_onchange_after_40-install-claude-code` keeps Claude Code CLI current automatically. `run_onchange_after_15-pnpm-globals` makes pnpm globals declarative from a YAML file. `run_onchange_after_20-configure-shell-tools` auto-generates completions and gh aliases. Together these make `chezmoi apply` fully self-contained on a fresh machine.

**What to add:** Copy these three scripts to `.chezmoiscripts/common/`; add `pnpm-globals.yaml` to `.chezmoidata/`
