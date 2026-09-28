# Dotfiles Handover — Shaunak vs Drew

Comparison of Shaunak Tavargeri's dotfiles against Drew's ([Drewtopia/dotfiles](https://github.com/Drewtopia/dotfiles)) as of 2026-05-12.

---

## What Drew has that Shaunak doesn't

### Dev Tooling

| Tool | What it does | Drew's config |
|------|-------------|---------------|
| **Jujutsu (jj)** | Alternative VCS built on git — cleaner history rewriting, first-class workspaces | `~/.config/jj/config.toml` with full alias set (`l`, `s`, `d`, `c`, `sq`, `pull`, `push`, `start`, `feat`, `tug`, `ready`, `wip`, `stale`) and custom revsets |
| **delta** | Syntax-highlighted git diff pager | Wired into `[core] pager` and `[diff]` in git config |
| **lazygit** | TUI git client | Minimal config (`empty_config.yml`) |
| **carapace** | Universal shell completion (bridges zsh/fish/bash) | Activated in `020-shell-tools.sh` |
| **pay-respects** | Rust replacement for `thefuck` | Bound to `f` alias in `030-system-tools.sh` |

### Terminal & Shell

| Tool | What it does | Notes |
|------|-------------|-------|
| **Ghostty** | Primary terminal | Config: `~/.config/ghostty/config` — ligatures off, `option-as-alt`, `shift+enter=\n` |
| **Television** | Channel-based fuzzy finder (smarter than fzf alone) | Ctrl+T in shell, activated via `tv init zsh` |
| **navi** | Interactive cheatsheet tool | Ctrl+\ binding |
| **glow** | Terminal markdown renderer | Available as CLI tool |
| **btop** | System monitor (vs htop) | Config tracked in `~/.config/btop/` |
| **zsh-autosuggestions** | Fish-like inline suggestions | Shaunak has this; Drew does not — keep it |

### Editor (Neovim)

Drew has a full tracked Neovim/LazyVim setup. Shaunak has `nvim` in the Brewfile but no tracked config.

Drew's nvim stack:
- LazyVim with **37 extras** (Claude Code AI, Copilot, DAP debug, Go, Python, TypeScript, SQL, Markdown, Git, Prettier, Black, refactoring, testing…)
- `tokyonight` colorscheme
- `chezmoi.nvim` integration — edit managed files directly in nvim
- `snacks.nvim` for picker/explorer with hidden file support
- Config lives in `~/.config/nvim/` with `lua/config/` and `lua/plugins/`

### Claude Code (`~/.claude/`)

Drew has his entire `~/.claude/` directory tracked in chezmoi. Shaunak does not.

Drew's setup includes:
- **CLAUDE.md** — global identity (GitHub handle, preferred VCS: jj, tooling: mise), security rules, auto-loaded rules directory
- **MCP servers**: Home Assistant (`ha-mcp`), Obsidian (`mcp-obsidian`), sequential-thinking
- **Custom skills**: `security-audit`, `jj-history-investigation`, `using-jj-workspaces`
- **Hooks**: PreToolUse (secret/danger validation), PostToolUse (post-edit actions), SessionStart (file permissions + git status)
- **Memory system**: `~/.claude/memory/` index + `~/.claude/rules/` auto-loaded

### Window Management

Drew uses **AeroSpace** (tiling WM) with named workspaces:

| Key | Workspace |
|-----|-----------|
| B | Browser |
| T | Terminal |
| M | Music (Spotify) |
| N | Notes/Obsidian |
| S | Social (Telegram, Messages) |
| W | Work (Jump Desktop) |
| 1–9 | General |

Auto-assignment rules match app names to workspaces on launch. `Alt+hjkl` navigation.

### Git

- **SSH commit signing** — Drew signs commits via 1Password SSH agent using `~/.ssh/id_ed25519.pub`
- **XDG-compliant git config** at `~/.config/git/config` (vs Shaunak's `~/.gitconfig`)
- **delta pager** wired in for diffs
- **nvimdiff** as merge tool
- **autoSquash + autoStash** enabled for rebase

### Kanata

Drew has three kbd files vs Shaunak's one:

| File | Purpose |
|------|---------|
| `shared.kbd` | Cross-platform layer definitions (home row mods, symbols, nav, hyper/meh) |
| `macos-macbook.kbd` | macOS built-in keyboard only (excludes QMK boards) |
| `windows.kbd` | Windows variant |

### Chezmoi Scripts (automation)

Drew has 10+ run scripts; Shaunak has 1 (kanata setup). Drew's scripts handle:
- `run_onchange_before_10-install-brew-packages.sh` — Homebrew install
- `run_after_10-install-mise-tools.sh` — mise tool install
- `run_onchange_after_40-install-claude-code.sh` — Claude Code CLI install
- `run_onchange_after_55-update-claude-marketplaces.sh` — Claude plugin updates
- `run_onchange_after_30-set-git-origin.sh` — git remote setup
- `run_onchange_after_50-setup-kanata.sh` — kanata service
- `run_onchange_after_60-configure-dock.sh` — macOS Dock layout

### Other Tools

- **fnox** — secrets manager (activated in shell)
- **topgrade** — system-wide upgrade tool with config at `~/.config/topgrade.toml`
- **atuin** secrets filter — blocks AWS keys, GitHub tokens, Slack webhooks, Stripe keys from history
- **XDG-compliant git config** location

---

## What Shaunak has that Drew doesn't

### Apps & Productivity

| Tool | Purpose |
|------|---------|
| **MacroWhisper** | Voice-to-text macros; config tracked (`macrowhisper.json`) with Kagi/Google URL actions |
| **BetterTouchTool** | Advanced trackpad/keyboard automation |
| **BetterDisplay** | Monitor management |
| **LinearMouse** | Mouse precision control |
| **Elgato Stream Deck** | Macro pad hardware |
| **Keyclu / ShowMeYourHotkeys** | Keyboard shortcut discovery |
| **Mouseless** | Keyboard-driven mouse control |
| **DockDoor** | Dock preview on hover |
| **AirBuddy** | AirPods battery/connection UI |
| **Lunar** | Display brightness control |
| **Ollama** | Local LLM inference |
| **Alt-Tab** | Window switcher (Exposé-style) |
| **zsh-autosuggestions** | Fish-like inline suggestions — Drew doesn't have this |

### Mac App Store Apps (selected)

Bear, rcmd, Velja, Kagi for Safari, Wipr, Baking Soda, Vinegar, Noir, Hyperduck, FiveNotes, UltraNotes, StopTheMadness Pro, keymapp, Spokenly, Raycast Companion, Dynamic Wallpaper, CloudMounter, Power Node

---

## Structural Differences

| Area | Shaunak | Drew |
|------|---------|------|
| Shell module numbering | `010`–`080` | `000`–`050` |
| Path management | Dedicated `path-management.sh` + `paths/` subdir | Inline in `000-paths.sh` |
| Git config location | `~/.gitconfig` | `~/.config/git/config` (XDG) |
| Terminal | Terminal.app | Ghostty |
| Primary VCS | git | jj (on top of git) |
| Commit signing | None tracked | SSH via 1Password |
| Cross-platform | macOS only | macOS + Linux + WSL + Windows |
| Leaderkey terminal entry | Terminal.app | Ghostty |
| Leaderkey window management | Raycast | Rectangle Pro |
| Claude Code tracking | Not tracked | Full `~/.claude/` in chezmoi |

---

## Suggested Adoptions (priority order)

1. **Track `~/.claude/`** — highest leverage; preserves Claude Code config, MCP servers, and memory across machines
2. **delta** — drop-in git diff upgrade; one brew install + a few git config lines
3. **AeroSpace** — if you want a tiling WM; Drew's workspace naming scheme is clean to copy
4. **Neovim config** — if you use nvim regularly, LazyVim is worth tracking
5. **Commit signing** — straightforward with 1Password SSH agent
6. **jj** — larger learning curve but Drew's alias set makes it approachable; good if you want better history rewriting
