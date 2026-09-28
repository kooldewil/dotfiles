# Dotfiles Handover — Shaunak vs Drew

Comparison of Shaunak Tavargeri's dotfiles against Drew's ([Drewtopia/dotfiles](https://github.com/Drewtopia/dotfiles)).

- **Shaunak's side:** checked against this repo on 2026-09-28.
- **Drew's side:** from the original 2026-05-12 snapshot. For Drew's newer additions (worktrunk, cvault, Node.js hook suite, WSL, Azure DevOps), see [`COMPARISON-Drewtopia.md`](COMPARISON-Drewtopia.md) (2026-07-24).

Since the first version of this doc, Shaunak has adopted almost everything on the original "Drew has, Shaunak doesn't" list.

---

## Adopted from Drew since 2026-05-12

| Tool | Shaunak's setup now |
|------|---------------------|
| **Jujutsu (jj)** | Installed via mise; config in `dot_config/jj/`. Claude Code hooks `jj-block-trunk.sh` and `jj-describe-claude.sh` |
| **delta** | Installed via mise; wired in as git `core.pager` and `interactive.diffFilter` (only when `delta` is on PATH) |
| **lazygit** | Installed via mise; config in `dot_config/lazygit/` |
| **carapace** | Installed via mise; activated in `050-shell-tools.sh.tmpl` |
| **pay-respects** | Installed via mise (cargo on macOS/Linux, GitHub release on Windows); bound to `f` |
| **Ghostty** | Primary terminal. Catppuccin Macchiato, MesloLGS NF 13, ligatures off, `macos-option-as-alt`, `shift+enter=\n` |
| **Television** | Installed via mise; `tv init zsh` in shell tools; cable channels in `dot_config/television/cable/` |
| **glow** | Installed via mise; config in `dot_config/glow/` |
| **Neovim (LazyVim)** | Tracked in `dot_config/nvim/`: 30 LazyVim extras, `tokyonight`, `chezmoi.nvim`, `snacks.nvim`, plus tmux navigation, surround and hardtime |
| **Claude Code (`~/.claude/`)** | Tracked in `dot_claude/`: `CLAUDE.md.tmpl`, `settings.json.tmpl`, `mcp.json`, hooks and custom skills (details below) |
| **AeroSpace** | Tracked in `dot_config/aerospace/`, with `borders` for window highlights. Workspaces 1–9 plus B (Browser), D (Development), M (Music), N (Notes), O (Other), S (Social), T (Terminal), W (Work); 13 app auto-assignment rules |
| **SSH commit signing** | Signs with `~/.ssh/id_ed25519.pub` via 1Password SSH agent (personal machines only) |
| **nvimdiff merge tool, autoSquash, autoStash** | All set in `dot_gitconfig.tmpl` |
| **Kanata split files** | `shared.kbd`, `macos-macbook.kbd`, `windows.kbd`, selected by `kanata.kbd.tmpl` |
| **topgrade** | Installed via mise; config at `dot_config/topgrade.toml` |
| **atuin history filter** | `history_filter` in `dot_config/atuin/config.toml.tmpl` drops `secret-*` commands and inline `VAR=value` env assignments |
| **Shell module numbering** | Now `000`–`070` (`000-paths` … `070-functions`), same scheme as Drew |
| **Windows support** | Scoop + PowerShell bootstrap scripts under `.chezmoiscripts/windows/` |

### Shaunak's Claude Code setup

- **Plugins (official marketplace):** superpowers, context7, security-guidance, skill-creator, code-review, feature-dev, commit-commands, code-simplifier, hookify, claude-md-management
- **MCP:** sequential-thinking only
- **Hooks:** own scripts for jj guardrails, memory sync (`memory-pull.sh` / `memory-push.sh`) and session-start git status; `after-edit.sh`, `block-dangerous-commands.sh`, `block-secrets.py`, `end-of-turn.sh` and `notify.sh` are pulled from TheDecipherist/claude-code-mastery via `.chezmoiexternal.toml.tmpl`
- **Custom skills:** `dotfiles-compare`, `fix-ebooks`, `handoff`, `homeserver`, `jumpdesktop-teams-diagnose`
- **External skills:** installed from `mattpocock/skills` and `vercel-labs/skills` via `.chezmoidata/skills.yaml` and a `run_onchange` script
- **Memory:** `~/.claude/memory/` synced to a private GitHub repo by the memory hooks
- **Permissions:** `git push` is denied for Claude; pushes are done by hand

---

## Still only in Drew's setup (as of the 2026-05-12 snapshot)

| Item | Notes |
|------|-------|
| **navi** | Interactive cheatsheets (Ctrl+\\). Shaunak uses plain-text cheatsheets in `dot_config/cheatsheets/` (chezmoi, git, shell, tmux) instead |
| **btop** | Tracked system monitor config |
| **fnox** | Secrets manager activated in the shell. Shaunak pulls secrets from 1Password at runtime |
| **XDG git config** | Drew uses `~/.config/git/config`; Shaunak still uses `~/.gitconfig` (`dot_gitconfig.tmpl`) |
| **Home Assistant + Obsidian MCP servers** | Shaunak has only sequential-thinking |
| **Drew's custom skills** | `security-audit`, `jj-history-investigation`, `using-jj-workspaces` |
| **Some chezmoi scripts** | Drew also has scripts for Homebrew packages, Claude Code install, git origin setup and Dock layout. Shaunak installs Homebrew packages from `Brewfile` via `install.sh`, not a chezmoi script |

---

## What Shaunak has that Drew doesn't

### Apps & Productivity (from `Brewfile`)

| Tool | Purpose |
|------|---------|
| **MacroWhisper** | Voice-to-text macros; config tracked in `dot_config/macrowhisper/` |
| **BetterTouchTool** | Advanced trackpad/keyboard automation |
| **BetterDisplay** | Monitor management |
| **LinearMouse** | Mouse precision control |
| **Elgato Stream Deck** | Macro pad hardware |
| **Keyclu** | Keyboard shortcut discovery |
| **Mouseless** | Keyboard-driven mouse control |
| **DockDoor** | Dock preview on hover |
| **AirBuddy** | AirPods battery/connection UI |
| **Lunar** | Display brightness control |
| **Ollama** | Local LLM inference |
| **Alt-Tab** | Window switcher (Exposé-style) |

### Mac App Store Apps (selected)

Bear, rcmd, Velja, Kagi for Safari, Wipr, Baking Soda, Vinegar, Noir, Hyperduck, FiveNotes, UltraNotes, StopTheMadness Pro, keymapp, Spokenly, Raycast Companion, Dynamic Wallpaper, CloudMounter, Power Node

### Other

- **tmux** with tpm (via `.chezmoiexternal`) and a built-in keybinding cheatsheet in `025-tmux.sh.tmpl`
- **Personal-only mise tools:** `yt-dlp`, `croc`
- **Zsh plugins via zinit:** `fzf-tab` and `zsh-syntax-highlighting`. `zsh-autosuggestions` was listed here in May, but it's no longer in the config

---

## Structural Differences

| Area | Shaunak (2026-09-28) | Drew (2026-05-12) |
|------|---------|------|
| Shell module numbering | `000`–`070` | `000`–`050` |
| Path management | `000-paths.sh.tmpl` plus separate `path-management.sh.tmpl` | Inline in `000-paths.sh` |
| Git config location | `~/.gitconfig` | `~/.config/git/config` (XDG) |
| Terminal | Ghostty | Ghostty |
| Primary VCS | jj (on top of git) | jj (on top of git) |
| Commit signing | SSH via 1Password (personal machines) | SSH via 1Password |
| Cross-platform | macOS + Windows (Scoop) | macOS + Linux + WSL + Windows |
| Window management | AeroSpace, plus Rectangle Pro driven from Leaderkey | AeroSpace; Rectangle Pro in Leaderkey |
| Leaderkey | Ghostty for terminal; Raycast and Rectangle Pro actions | Ghostty; Rectangle Pro |
| Homebrew packages | `Brewfile` applied by `install.sh` | chezmoi `run_onchange` script |
| Claude Code tracking | `dot_claude/` in chezmoi | Full `~/.claude/` in chezmoi |

---

## Suggested Adoptions (priority order)

The original list (track `~/.claude/`, delta, AeroSpace, Neovim, commit signing, jj) is done. What's left:

1. **Own your Claude Code hooks** instead of pulling them from TheDecipherist/claude-code-mastery, so upstream changes can't silently change their behaviour
2. **XDG git config** (`~/.config/git/config`), if you want everything under `~/.config`
3. **navi**, if the plain-text cheatsheets start to feel limiting
4. **btop** config, if you use it
5. **Move `Brewfile` into a chezmoi `run_onchange` script**, so new apps install on `chezmoi apply` rather than only on first bootstrap

See [`COMPARISON-Drewtopia.md`](COMPARISON-Drewtopia.md) for ideas from Drew's newer setup (Stop-hook quality gate, hook-bypass countermeasure, `modify_settings.json.tmpl`, worktrunk).
