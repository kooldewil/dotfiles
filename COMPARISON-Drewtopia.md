# Dotfiles Comparison: You vs Drewtopia

*Generated: 2026-05-23 | Source: Drewtopia/dotfiles (main branch)*

---

## Section 1: Tools/configs Drew has that you don't

### Claude Code / AI tooling

| Item | Description | Location |
|------|-------------|----------|
| Home Assistant MCP | Controls smart home devices from Claude | `dot_claude/mcp.json.tmpl` (conditional on `.personal`) |
| Obsidian MCP | Reads/searches Obsidian vault from Claude | `dot_claude/mcp.json.tmpl` |
| `superpowers` plugin | Official Claude Code marketplace plugin | `dot_claude/settings.json.tmpl` |
| `context7` plugin | Official Claude Code marketplace plugin | `dot_claude/settings.json.tmpl` |
| `security-guidance` plugin | Official Claude Code marketplace plugin | `dot_claude/settings.json.tmpl` |
| Claude memory backup script | Backs up memory dir before chezmoi apply | `.chezmoiscripts/common/run_before_03-backup-claude-memory.sh` |
| Caveman marketplace | Second Claude Code marketplace source | `dot_claude/settings.json.tmpl` |
| Private vault symlinks | Memory, rules, agents in a separate encrypted repo | `dot_claude/symlink_memory.tmpl`, `symlink_rules.tmpl` |
| External skills (claude-code-mastery) | Skills from TheDecipherist/claude-code-mastery via `.chezmoiexternal` | `.chezmoiexternal.toml.tmpl` |

### Dev tooling

| Item | Description | Location |
|------|-------------|----------|
| `fnox` | Secrets injection into shell environment | `dot_config/shell/020-shell-tools.sh.tmpl` |
| `pay-respects` | Command corrector (like `thefuck`) | `dot_config/shell/020-shell-tools.sh.tmpl` |
| `topgrade` reminder script | Post-apply reminder to run `topgrade` | `.chezmoiscripts/common/run_after_99-topgrade-reminder.sh.tmpl` |
| `run_onchange_after_30-set-git-origin` | Auto-sets git remote origin to SSH on apply | `.chezmoiscripts/common/` |
| `pnpm-globals` script | Configures pnpm global packages on apply | `.chezmoiscripts/common/run_onchange_after_15-pnpm-globals.sh.tmpl` |
| Windows Claude install script | Installs Claude Code on Windows via chezmoi | `.chezmoiscripts/common/run_onchange_after_40-install-claude-code.ps1.tmpl` |

### SSH / Secrets

| Item | Description | Location |
|------|-------------|----------|
| RSA key pair managed | Both Ed25519 + RSA managed in chezmoi | `dot_ssh/id_rsa.pub.tmpl`, `dot_ssh/private_id_rsa.tmpl` |
| Private SSH key in chezmoi | Private key stored encrypted via 1Password+chezmoi | `dot_ssh/private_id_ed25519.tmpl` |
| WSL GitHub via port 443 | Routes GitHub SSH through port 443 to bypass firewalls | `dot_ssh/config.tmpl` |
| Azure DevOps SSH | RSA key support for Azure DevOps (no Ed25519) | `dot_ssh/config.tmpl` |

### Terminal & shell

| Item | Description | Location |
|------|-------------|----------|
| `zsh-active-cheatsheet` via external | External chezmoi-managed zsh cheatsheet integration | `.chezmoiexternal.toml.tmpl` |
| Catppuccin themes via external | eza/yazi/btop themes managed as external files | `.chezmoiexternal.toml.tmpl` |
| CUE tool | Data constraint language (Linux only) | `.chezmoiexternal.toml.tmpl` |

### Automation (chezmoi scripts)

| Item | Description | Location |
|------|-------------|----------|
| `.chezmoiexternal.toml.tmpl` | Manages Oh-My-Zsh, p10k, plugins, tmux plugins, themes as externals | repo root |
| Darwin: `run_onchange_before_20-install-1password.sh` | Auto-installs 1Password on macOS | `.chezmoiscripts/darwin/` |

---

## Section 2: Tools/configs you have that Drew doesn't

### Apps / GUI

| Item | Description | Location |
|------|-------------|----------|
| MacroWhisper config | Voice dictation app configuration | `dot_config/macrowhisper/macrowhisper.json` |
| Lazygit config | TUI git client (Drew uses via LazyVim but no standalone config) | `dot_config/lazygit/empty_config.yml` |

### Terminal & shell

| Item | Description | Location |
|------|-------------|----------|
| `tmux.reset.conf` | Tmux reset/defaults file separate from main config | `dot_config/tmux/tmux.reset.conf` |
| `070-functions.sh` | Utility shell functions: `mkcd`, `tmpd`, `up`, `cl`, `extract`, `serve`, `repos` | `dot_config/shell/070-functions.sh` |
| `010-history.sh` | Dedicated history config module (HISTSIZE=50000, timestamps) | `dot_config/shell/010-history.sh` |
| `020-completion.sh` | Dedicated zsh completion tuning module | `dot_config/shell/020-completion.sh` |
| `path-management.sh.tmpl` | Standalone path management script | `dot_config/path-management.sh.tmpl` |

### Dev tooling

| Item | Description | Location |
|------|-------------|----------|
| television cable configs | Custom TV channel definitions for fuzzy finding | `dot_config/television/cable/*.toml` |
| Glow config | Markdown terminal viewer configuration | `dot_config/glow/glow.yml` |

### Claude Code / AI tooling

| Item | Description | Location |
|------|-------------|----------|
| `fix-ebooks` skill | Fixes EPUB formatting issues | `dot_claude/skills/fix-ebooks/SKILL.md` |
| `handoff` skill | Compact conversation for agent handoff | `dot_claude/skills/handoff/SKILL.md` |
| `dotfiles-compare` skill | This very skill | `dot_claude/skills/dotfiles-compare/SKILL.md` |

---

## Section 3: Structural differences

| Area | You | Drew |
|------|-----|------|
| Shell framework | Oh-My-Zsh + Powerlevel10k + Zinit | Oh-My-Zsh + Powerlevel10k + Zinit |
| Shell modules | 8 numbered files (000–070) | 7 numbered files (000–050) |
| Terminal | Ghostty (catppuccin-macchiato) | Ghostty (different keybindings) |
| Primary VCS | Git (+ jj on dev machines) | Git (+ jj on dev machines) |
| Git config location | `dot_gitconfig.tmpl` (repo root) | `dot_config/git/config.tmpl` (XDG) |
| Cross-platform | macOS + Windows | macOS + Linux + Windows + WSL |
| Secret management | 1Password (SSH agent, git signing) | 1Password (SSH agent, git signing, fnox) |
| SSH keys tracked | Public key + authorized_keys only | Public + private keys + authorized_keys |
| SSH key types | Ed25519 only | Ed25519 + RSA (Azure DevOps compat) |
| Commit signing | SSH via 1Password | SSH via 1Password |
| Chezmoi scripts | 5 scripts | 10+ scripts (+ git-origin, pnpm, topgrade, Claude install, memory backup) |
| `.chezmoiexternal` | Not used | Manages OMZ, p10k, plugins, tmux plugins, themes, CUE, Neovim |
| MCP servers | 1 (sequential-thinking) | 3 (sequential-thinking + ha-mcp + mcp-obsidian) |
| Claude marketplaces | 1 (official) | 2 (official + caveman) |
| Claude plugins | core set | core set + superpowers + context7 + security-guidance |
| Claude memory | Direct files in `~/.claude/memory/` | Private encrypted vault repo via symlinks |
| Leaderkey / launcher | Raycast + LeaderKey | Raycast + LeaderKey |
| Editor | Neovim (LazyVim, 30+ extras) | Neovim (LazyVim, 37 extras) |
| Window manager | AeroSpace | AeroSpace |

---

## Section 4: Suggested adoptions (ranked)

**1. `.chezmoiexternal.toml.tmpl` for external managed files**
Drew manages Oh-My-Zsh, Powerlevel10k, tmux plugins, and Catppuccin themes as chezmoi externals rather than assuming they're pre-installed. This means `chezmoi apply` on a fresh machine installs everything automatically — no manual plugin installs required.

**2. Private vault repo for Claude memory/rules**
Drew symlinks `~/.claude/memory/` and `~/.claude/rules` to a separate private encrypted git repo. Your memory currently lives in `~/.claude/memory/` untracked. Moving it to a private vault means memory syncs across machines automatically and is backed up, while staying out of your public dotfiles.

**3. More MCP servers (Home Assistant + Obsidian)**
Drew conditionally enables ha-mcp for smart home control and mcp-obsidian for note access from Claude. If you use Home Assistant or Obsidian, these give Claude direct access to your home and knowledge base.

**4. `fnox` for secrets injection**
Drew uses `fnox` to inject secrets into the shell environment at load time (from 1Password), keeping secret env vars like `$ANTHROPIC_API_KEY` and `$GITHUB_TOKEN` out of dotfiles while making them available to all tools.

**5. `run_before` Claude memory backup + `run_onchange` for git origin**
Two small automation improvements: backing up Claude memory before every `chezmoi apply` (guards against symlink replacement accidents), and auto-setting the git remote origin to SSH on apply (so a fresh clone uses the right remote without manual steps).

---

## Direct answer: SSH question

**Yes** — Drew fully manages SSH as dotfiles via chezmoi:
- `dot_ssh/config.tmpl` — host configs, 1Password agent, WSL/firewall workarounds, Azure DevOps
- `dot_ssh/id_ed25519.pub.tmpl` — public key templated from 1Password
- `dot_ssh/private_id_ed25519.tmpl` — **private key** stored encrypted via chezmoi+1Password
- `dot_ssh/id_rsa.pub.tmpl` + `private_id_rsa.tmpl` — RSA pair for Azure DevOps
- `dot_ssh/authorized_keys.tmpl`

You also manage SSH via chezmoi (`dot_ssh/config.tmpl`, `id_ed25519.pub.tmpl`, `authorized_keys.tmpl`) but don't track the private key. Drew goes one step further by storing the private key encrypted in the repo, pulled from 1Password at apply time.
