# Dotfiles Comparison: yours vs. Drewtopia/dotfiles

*Generated: 2026-10-21 | Source: Drewtopia/dotfiles (main, commit `dbc91ed`, local clone pulled the same day) | Supersedes the 2026-07-24 version. Drew made 123 commits since 2026-09-28; the big themes are dcg, worktrunk + Orca worktree flow, ~/.claude/mods, age-encrypted work files, T3 Code server, and moving every install through mise.*

Note on file location: this file lives at the repo root, not in `home/` (the `.chezmoiroot`), so chezmoi never applies it to `~`.

**Already adopted from Drew:** dcg (2026-10-21, with `platform.github`, `platform.azure_devops` and his `azure-writes` pack); the `10-install-mise-tools` script (2026-10-21); the `modify_settings.json` merge (2026-10-21, managed wins on scalars except `enabledPlugins`, unlike Drew's runtime-wins); skills `find-session`, `flow-check`, `audit-skill-repos` (adapted) and `azure-repos`; the T3 Code tailnet server LaunchAgent; ccstatusline via mise with tracked config; Drew's commit precheck (gitleaks on staged files) extended with `commit-check` on the message after each Claude commit. Not adopted: his branch-name push gate (you commit to `main` and Claude can't push).

---

## Section 1: Tools/configs Drew has that you don't

### Claude Code / AI tooling
| Item | Description | Location |
|---|---|---|
| `modify_settings.json` + `claude-settings-merge` | jq merge of a managed floor into the *live* settings.json, so runtime writes (dcg's hook, `/auto-mode-setup`'s `autoMode` block, plugin toggles) survive `chezmoi apply`. Also retires old hooks explicitly | `dot_claude/modify_settings.json.tmpl`, `.chezmoitemplates/claude-settings-merge` |
| Self-authored Node.js hook suite with tests | `pre-bash-dispatcher.js`, `block-secrets.js`, `post-edit-format.js`, `notify.js`, `cwd-changed-worktree-check.js`, `edit-governance-guard.cjs`, `post-commit-clear-nudge.js`; `tests/` dir | `dot_claude/hooks/` |
| `git-commit-precheck.sh` + `commit-check` | Push/commit gate enforcing Conventional Commits + Conventional Branch, and countering `-c core.hooksPath=/dev/null` bypass. `commit-check` installed via `pipx:` in mise | `dot_claude/hooks/`, `dot_config/commit-check/` |
| `~/.claude/mods` | Each folder under `~/.claude/mods` loads as a Claude Code plugin from zsh; guarded by hooks | `dot_config/zsh/`, `dot_claude/hooks/` |
| ccstatusline (installed + configured) | Status line config tracked in repo; installed as a mise `npm:` tool so repaints don't go through `bun x` | `dot_config/ccstatusline/settings.json`, mise config |
| Custom skills | `catch-up` (re-entry briefing per worktree), `find-session` (fuzzy search past sessions), `flow-check` (find undecided/unhomed threads), `close`, `reconcile-tracker`, `edit-governance`, `homelab-ops`, `audit-*`, `reorganize-memory` | `dot_claude/skills/` |
| Extra skill repos | `chief-of-staff`, `claude-handoff`, `loop-me` (mattpocock), `conventional-branch`, `playwright-cli`, `humanizer`, `azure-repos` (microsoftdocs), `orca-cli`, `shadcn/improve`, `anti-slop` | `.chezmoidata/skills.yaml` |
| 13 plugin marketplaces | Adds `i-have-adhd`, `obsidian-skills`, `qmd`, `superpowers-extended`, `ecc`, `worktrunk`, `humanizer`, `superwhisper`, `pstack-claude`; profile-gated `[plugins.always/personal/dev_computer]` with `false` as a rejection record | `.chezmoidata/claude.toml` |
| CLI-ified agent tools | `@playwright/cli`, `ctx7` (library docs) instead of per-session MCP servers; also `defuddle`, `qmd` (local markdown search), `@openai/codex` | `dot_config/mise/config.toml.tmpl` |
| Claude session tools | `claude-ls`, `claude-tail`, `claude-log-session` | `dot_local/bin/` |

### Dev tooling / VCS
| Item | Description | Location |
|---|---|---|
| worktrunk (`wt`) + Orca | Worktree manager: `wt new`/`resume`, `wt step land`, `ship` alias builds PR body from commits, `wt-attic` saves untracked files before removal; worktrees open as Orca tabs | `dot_config/worktrunk/`, `dot_local/bin/executable_wt-*` |
| age-encrypted work files | Work-only config (worktrunk work config, Azure Repos git include) committed encrypted | `encrypted_*.age` files |
| Azure DevOps git integration | `useHttpPath`, conditional SSH signing via `includeIf`, `.git-azdo-helper.sh` | `dot_config/git/` |
| XDG git config | `~/.config/git/config` + `ignore` + `allowed_signers` | `dot_config/git/` |
| Repo self-governance | `.changeset/` + `CHANGELOG.md`, Pester tests, `GLOSSARY.md`, `AGENTS.md`, `docs/agents/` | repo root |

### Terminal & shell
| Item | Description | Location |
|---|---|---|
| herdr | Agent-aware terminal multiplexer; persists panes and resumes Claude sessions after reboot | `dot_config/herdr/`, mise config |
| yazi, navi, btop | File manager, cheatsheet launcher, system monitor | mise config, `dot_config/` |
| WezTerm + WSL | WezTerm for work Windows; `.wslconfig`, `.bashrc`, `.profile` | `dot_wezterm.lua.tmpl`, `dot_wslconfig.tmpl` |
| `fnox` vault shell file | Secrets rendered at apply time into a private shell module | `dot_config/shell/private_015-vault.sh.tmpl` |

### Automation (chezmoi scripts)
| Item | Description | Location |
|---|---|---|
| T3 Code server as a LaunchAgent | `t3 serve` bound to the Mac's Tailscale IP on 3773, separate state dir, launchd restarts it | `dot_local/bin/executable_t3-serve-tailnet`, `darwin/run_onchange_after_70-load-t3-serve.sh.tmpl` |
| Dock configuration | `dockutil` removes stock apps on apply | `darwin/run_onchange_after_60-configure-dock.sh` |
| Brew packages on apply | `run_onchange` brew script, so new casks install on `chezmoi apply` | `darwin/run_onchange_before_10-install-brew-packages.sh.tmpl` |
| Claude Code install, MCP server sync, plugin-permission fix, skill reconcile, memory backup, topgrade reminder | More of the Claude setup is scripted | `.chezmoiscripts/common/` |
| Corporate-Windows relocation, winget, PowerShell modules | Work Windows support | `.chezmoitemplates/windows-relocation`, `.chezmoiscripts/windows/` |

---

## Section 2: Tools/configs you have that Drew doesn't

### Claude Code / AI tooling
| Item | Description | Location |
|---|---|---|
| `dotfiles-compare`, `fix-ebooks`, `handoff`, `homeserver`, `jumpdesktop-teams-diagnose` skills | No overlap with Drew's custom skills | `dot_claude/skills/` |
| jj hooks for Claude | `jj-block-trunk`, `jj-describe-claude` | `dot_claude/hooks/` |
| Memory sync hooks | `memory-pull.sh` / `memory-push.sh` to `kooldewil/claude-memory` | `dot_claude/hooks/` |
| mattpocock engineering skills | `tdd`, `to-prd`, `to-issues`, `triage`, `prototype`, `zoom-out`, `teach` | `.chezmoidata/skills.yaml` |

### Automation / macOS
| Item | Description | Location |
|---|---|---|
| Learn lesson server | `~/Learn` served on the tailnet from the Mac mini | `private_Library/LaunchAgents/com.shaunakt.learn-server.plist` |
| Weekday display caffeinate | Keeps Mac mini displays awake until 17:30 | `com.shaunakt.workday-caffeinate.plist` |
| Personal mise tools | `yt-dlp`, `croc` | mise config |
| Bootstrap Brewfile | 58 casks + MAS apps, run once by `install.sh` | `Brewfile`, `install.sh` |

---

## Section 3: Structural differences

| Area | You | Drew |
|---|---|---|
| Shell framework | oh-my-zsh + Powerlevel10k + Zinit | Same, plus ZDOTDIR layout and `fnox` |
| Terminal / multiplexer | Ghostty + tmux | Ghostty + WezTerm (Windows) + herdr / tmux / psmux |
| Primary VCS workflow | jj + Claude jj hooks | jj + worktrunk/Orca worktree-per-branch flow |
| Git config location | `dot_gitconfig.tmpl` | `dot_config/git/config.tmpl` (XDG) + encrypted includes |
| Cross-platform | macOS + Windows (Scoop) | macOS + Windows (Scoop/winget via mise) + WSL2 + Linux |
| Secret management | 1Password, runtime `op` reads | 1Password + `fnox` + age-encrypted files |
| Commit signing | SSH via 1Password | Same, plus Azure DevOps signing via `includeIf` |
| Claude settings | `modify_` jq merge over live settings (managed wins on scalars) | `modify_` jq merge over live settings (runtime wins on scalars) |
| Claude hooks | Vendored from external repo via `.chezmoiexternal` + a few own scripts | All self-authored Node.js, tested, in-repo; plus dcg |
| Chezmoi scripts | mise bootstrap → mise tools → 1Password → kanata → caffeinate/learn → marketplaces → skills | Same, plus brew, Dock, T3 serve, Claude install, MCP sync, skill reconcile |
| Leaderkey / launcher | Present | Present |

---

## Section 4: Suggested adoptions (ranked)

**1. `modify_settings.json` merge**
Today's DCG install showed the cost of a plain template: `chezmoi apply` would have stripped dcg's hook, and it will still strip the `autoMode` block `/auto-mode-setup` wrote — a merge lets runtime writers and chezmoi coexist.

**2. T3 Code server as a LaunchAgent**
You already host T3 Code on the Mac mini for other devices; Drew's script binds `t3 serve` to the tailnet IP under launchd, so it survives restarts without the desktop app being open or logged in.

**3. Push/commit precheck with `commit-check`**
Enforces your Conventional Commits style and blocks hook bypass, which matters now that Claude does more of your commits.

**4. ccstatusline config + CLI-ified agent tools (`playwright-cli`, `ctx7`)**
Cheap wins: a tracked status line, and browser/docs tools as CLIs rather than per-session MCP servers.

**5. herdr**
Since the Mac mini runs long agent sessions, a multiplexer that resumes Claude sessions after a reboot fits your setup — try it before adopting worktrunk/Orca, which is tuned to Drew's Azure work flow.
