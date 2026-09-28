# Dotfiles Comparison: yours vs. Drewtopia/dotfiles

*Generated: 2026-07-24 | Source: Drewtopia/dotfiles (main branch, commit `20f62f3`) | Supersedes the 2026-05-23 version of this file — Drew's repo has changed substantially since then (worktrunk, cvault, self-authored Node.js hooks, Azure DevOps git integration, WSL support, and commit-check policy enforcement are all new additions).*

Note on file location: Drew's `.chezmoiroot` points at `home/`, same as yours, but this file is written to the **repo root** (`~/.local/share/chezmoi/COMPARISON-Drewtopia.md`) rather than inside `home/` — putting it inside `home/` would make chezmoi treat it as a dotfile to apply to `~/COMPARISON-Drewtopia.md`.

---

## Section 1: Tools/configs Drew has that you don't

### Claude Code / AI tooling
| Item | Description | Location |
|---|---|---|
| Self-authored Node.js hook suite (with unit tests) | `block-secrets.js`, `notify.js`, `post-edit-format.js`, `pre-bash-dispatcher.js`, `session-start-git-status.js`, `warn-derived-artifact.js`, `warn-edit-on-protected.js`, `warn-worktree-convention.js` | `dot_claude/hooks/` |
| `stop-end-of-turn.js` quality gate | Runs lint/typecheck/secret-scan on every Stop event before Claude can end a turn | `dot_claude/hooks/stop-end-of-turn.js` |
| `modify_settings.json.tmpl` | `jq` deep-merge of a managed settings floor into the *live* settings.json, so Claude's own runtime writes survive `chezmoi apply` | `dot_claude/modify_settings.json.tmpl` |
| `cvault` CLI + `claude-vault` external repo | Memory/rules symlinked from a separate git repo, managed by a full custom CLI (status/diff/apply/update/sync/merge) | `dot_local/bin/executable_cvault`, `dot_claude/symlink_memory.tmpl` |
| `git-commit-precheck.sh` + `commit-check`/`cchk.toml` | Lefthook/gitleaks-style pre-commit fallback specifically countering Claude bypassing hooks via `-c core.hooksPath=/dev/null`; enforces Conventional Branch naming | `dot_claude/executable_git-commit-precheck.sh`, `dot_config/commit-check/cchk.toml` |
| Profile-gated plugin enablement | `always`/`personal`/`dev_computer` tables with inline rationale for retired plugins | `.chezmoidata/claude.toml` |
| 11 plugin marketplaces (vs. your 6) | Includes `i-have-adhd`, `mattpocock`, `superpowers-extended`, `worktrunk` | `.chezmoidata/claude.toml` |
| `worktrunk` | Worktree manager; places worktrees under `.claude/worktrees/<branch>`, LLM-generated commit/squash messages via hermetic `claude -p --model=haiku --safe-mode` | `dot_config/worktrunk/config.toml` |
| `ha-mcp` (Home Assistant) + `mcp-obsidian` MCP servers | You only have `sequential-thinking` | `dot_claude/mcp.json.tmpl` |
| GitHub Copilot instructions | Parallel/lighter version of CLAUDE.md ported for Copilot | `dot_github/copilot-instructions.md.tmpl` |
| `close`, `reorganize-memory`, `audit-skill-repos`, `audit-rules-and-skills` skills | Elaborate session-closeout (Open Brain capture, memory writes, commit splitting, SESSION_LOG.md) and memory/rules hygiene tooling | `dot_claude/skills/` |

### Dev tooling / VCS
| Item | Description | Location |
|---|---|---|
| Azure DevOps git integration | `useHttpPath`, WSL→Windows `ssh.exe` routing, custom `.git-azdo-helper.sh`, conditional SSH commit signing via `includeIf` | `dot_config/git/config.tmpl`, `executable_dot_git-azdo-helper.sh` |
| Repo self-governance | `.changeset/` + `CHANGELOG.md` for versioning the dotfiles repo itself, `tests/` with Pester unit tests for Windows-relocation logic, `CONTEXT.md` domain vocabulary, `AGENTS.md` + `docs/agents/` (issue-tracker, triage-labels, domain docs) | repo root, `docs/` |
| `fnox` secrets-manager shell activation | Secrets rendered at chezmoi apply-time into a private shell file (vs. your runtime 1Password pull) | `dot_config/shell/020-shell-tools.sh.tmpl`, `private_015-vault.sh.tmpl` |

### Terminal & shell
| Item | Description | Location |
|---|---|---|
| WezTerm config | Secondary terminal, default on work Windows machines (routes into WSL2 Ubuntu domain) | `dot_wezterm.lua.tmpl` |
| Full WSL support | `.wslconfig` tuning (no GPU, no DNS proxy, no localhost forwarding), `.bashrc`/`.profile` for WSL shells | `dot_wslconfig.tmpl`, `dot_bashrc.tmpl`, `dot_profile.tmpl` |
| `btop`, `navi` configs | You have neither | `dot_config/btop/`, `dot_config/navi/` |

### Automation (chezmoi scripts) / Windows
| Item | Description | Location |
|---|---|---|
| Corporate-Windows "relocation" model | Detects locked-down endpoint-security path restrictions and relocates tool installs to a whitelisted folder; combines Scoop + Winget | `.chezmoi.toml.tmpl`, `.chezmoitemplates/windows-relocation` |
| `executable_op.tmpl` | 1Password CLI shim through Windows interop for native Linux/WSL `op` | `dot_local/bin/executable_op.tmpl` |
| Dock cleanup, VS Code extension relocation, font registration, PowerShell module install | Additional bootstrap scripts you don't have | `.chezmoiscripts/darwin/`, `.chezmoiscripts/windows/` |

### Apps (GUI)
| Item | Description | Location |
|---|---|---|
| Full Brewfile with ~35 casks | Arc, Hammerspoon, Hazel, Home Assistant, Plex, Raindrop.io, Tailscale, VS Code, WezTerm, Zen, etc. — with inline comments on deliberately excluded casks | `.chezmoiscripts/darwin/run_onchange_before_10-install-brew-packages.sh.tmpl` |
| VS Code `mcp.json.tmpl` | Windows work-machine specific | `Library/Application Support/Code/` |

---

## Section 2: Tools/configs you have that Drew doesn't

### Claude Code / AI tooling
| Item | Description | Location |
|---|---|---|
| `dotfiles-compare`, `fix-ebooks`, `handoff`, `jumpdesktop-teams-diagnose` skills | No overlap with Drew's custom skill set at all | `dot_claude/skills/` |

### Dev tooling
| Item | Description | Location |
|---|---|---|
| `yt-dlp`, `croc` (personal-only mise tools) | Not in Drew's tool list | `dot_config/mise/config.toml.tmpl` |
| Bootstrap-time Brewfile | chezmoi scripts install only `mise` and the 1Password CLI; CLI tools come from mise. GUI apps come from a repo-root `Brewfile` (55 casks, 31 Mac App Store apps) that `install.sh` runs with `brew bundle` on first setup. Unlike Drew's `run_onchange` script, new Brewfile entries aren't installed by `chezmoi apply` | `Brewfile`, `install.sh`, `.chezmoiscripts/darwin/` |

---

## Section 3: Structural differences

| Area | You | Drew |
|---|---|---|
| Shell framework | oh-my-zsh + Powerlevel10k + Zinit | Same, plus `fnox` secrets activation |
| Terminal | Ghostty only | Ghostty (macOS) + WezTerm (Windows/WSL) |
| Primary VCS workflow | jj w/ custom revsets + Claude hooks (`jj-block-trunk`, `jj-describe-claude`) | jj w/ similar revset/alias design, plus Azure DevOps git config for work |
| Git config location | `dot_gitconfig.tmpl` (repo root) | `dot_config/git/config.tmpl` (XDG path) + `config.local` include |
| Cross-platform | macOS + Windows (Scoop) | macOS + Windows (Scoop+Winget) + WSL2 + "relocated" corporate Windows |
| Secret management | 1Password, tokens pulled at shell **runtime** | 1Password + `fnox`, secrets rendered at chezmoi **apply-time** |
| Commit signing | SSH via 1Password (personal machines) | Same, plus conditional Azure DevOps signing path via `includeIf` |
| Chezmoi scripts | mise bootstrap → 1Password CLI → kanata/Karabiner → Claude marketplace sync → skills install | Same categories, plus Dock cleanup, VS Code extension relocation, font registration, PowerShell modules |
| Claude Code hooks | Shell/Python, sourced from an external repo via `.chezmoiexternal.toml` | Self-authored Node.js, with unit tests, in-repo |
| Claude memory sync | Two hook scripts syncing `~/.claude/memory` to a GitHub repo | Symlinked external `claude-vault` repo + dedicated `cvault` CLI |
| Leaderkey / launcher | Present, same action-tree structure (browsers/open/raycast/screenshot/window mgmt via Rectangle Pro) | Present, same structure, different app bindings (adds Jump Desktop shortcut for work) |

---

## Section 4: Suggested adoptions (ranked)

**1. `stop-end-of-turn.js`-style quality gate**
A Stop hook running lint/typecheck/secret-scan before Claude can end a turn. Strengthens your existing `end-of-turn.sh`/`after-edit.sh` hooks by catching broken code before you see it.

**2. Pre-commit hook-bypass countermeasure**
Your `settings.json.tmpl` denies `git push` outright, but nothing stops Claude from disabling your *other* local git hooks via `-c core.hooksPath=/dev/null`. Drew's `git-commit-precheck.sh` fallback closes that gap.

**3. `modify_settings.json.tmpl` deep-merge pattern**
Claude Code writes to `settings.json` at runtime (plugin toggles, telemetry state); a plain chezmoi template will stomp those writes on the next `apply`. The `jq`-merge approach lets both sides coexist.

**4. Own your Claude Code hooks instead of vendoring them externally**
You currently pull `block-secrets.py`, `notify.sh`, etc. from `TheDecipherist/claude-code-mastery` via `.chezmoiexternal.toml`. Drew's in-repo, tested, self-authored equivalents remove that supply-chain dependency and give you full control over behavior.

**5. `worktrunk`**
Given you already run a jj + git-worktree workflow (your `jj-block-trunk`/`jj-describe-claude` hooks), worktrunk's LLM-generated commit/squash messages and standardized worktree location (`.claude/worktrees/<branch>`) is a low-risk addition that fits what you've already built.
