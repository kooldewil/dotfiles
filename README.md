# Shaunak's Dotfiles

Personal dotfiles for macOS, managed with [chezmoi](https://www.chezmoi.io/).

## Features

- **Modular shell configuration** - Split into logical modules for easy maintenance
- **Powerlevel10k** - Fast, customizable zsh theme with instant prompt
- **Oh My Zsh** - Framework for zsh configuration
- **Zinit** - Fast plugin manager for zsh-autosuggestions, syntax-highlighting, fzf-tab
- **Modern CLI tools** - zoxide (smarter cd), atuin (better history), mise (runtime manager)
- **Chezmoi templates** - Machine-specific configuration via template variables

## Quick Start

Install on a new Mac:

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kooldewil

# Install Homebrew packages
brew bundle --file=~/.local/share/chezmoi/Brewfile

# Initialize chezmoi (creates config with template variables)
chezmoi init

# Apply dotfiles
chezmoi apply
```

## What's Included

### Shell Configuration
- **Powerlevel10k theme** with instant prompt
- **Modular configs** in `~/.config/shell/`:
  - `010-history.sh` - History settings (50k entries, XDG-compliant)
  - `020-completion.sh` - Completion system with caching
  - `050-shell-tools.sh` - zoxide, atuin, fzf integration
  - `060-common_aliases.sh` - Navigation, git, chezmoi, macOS aliases
  - `070-functions.sh` - Custom functions (mkcd, extract, serve, etc.)
  - `080-mise.sh` - mise runtime manager activation
- **Path management** in `~/.config/shell/paths/`

### External Dependencies (managed by chezmoi)
- Oh My Zsh (`~/.oh-my-zsh/`)
- Powerlevel10k theme (`~/.oh-my-zsh/custom/themes/powerlevel10k/`)
- Zinit plugin manager (`~/.local/share/zinit/`)

### Zinit Plugins
- `fzf-tab` - Fuzzy completion with fzf
- `zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-syntax-highlighting` - Syntax highlighting for commands

### Tool Configurations
- **atuin** (`~/.config/atuin/`) - Enhanced shell history
- **mise** (`~/.config/mise/`) - Runtime version manager (node, python, go)

### Homebrew Packages
See `Brewfile` for full list. Highlights:
- CLI: chezmoi, eza, bat, ripgrep, fd, fzf, jq
- Shell tools: zoxide, atuin, mise
- Fonts: Meslo LG Nerd Font (for Powerlevel10k icons)

## Template Variables

Chezmoi uses these variables for machine-specific configuration:

| Variable | Description |
|----------|-------------|
| `name` | Your full name |
| `email` | Your email address |
| `personal` | Is this a personal machine? |
| `dev_computer` | Is this a development machine? |
| `ephemeral` | Is this a temporary/ephemeral machine? |

Edit `~/.config/chezmoi/chezmoi.toml` to change these values.

## Manual Setup

After installation:

1. **Configure Powerlevel10k**: Run `p10k configure` to customize the prompt
2. **Install mise runtimes**: Run `mise install` to install configured runtimes
3. **Sync atuin** (optional): Run `atuin login` to sync history across machines

App-specific:
- **Stream Deck**: Import profiles from backup
- **BetterTouchTool**: Import presets after installation
- **Raycast**: Sign in and sync settings
- **1Password**: Sign in to enable integrations

## Updating

```bash
chezmoi update
```

## Structure

```
.
├── .chezmoi.toml.tmpl           # Template variables configuration
├── Brewfile                      # Homebrew packages
├── install.sh                    # Installation script
├── .chezmoiroot                  # Points to home/ as source root
└── home/
    ├── .chezmoiexternal.toml.tmpl  # External dependencies (Oh My Zsh, p10k, Zinit)
    ├── dot_zshrc.tmpl              # Main zsh configuration
    ├── dot_gitconfig.tmpl          # Git configuration
    ├── dot_p10k.zsh                # Powerlevel10k configuration
    └── dot_config/
        ├── shell-loader.sh.tmpl    # Sources all shell modules
        ├── path-management.sh.tmpl # PATH manipulation functions
        ├── shell/                  # Modular shell configs
        │   ├── 010-history.sh
        │   ├── 020-completion.sh
        │   ├── 050-shell-tools.sh.tmpl
        │   ├── 060-common_aliases.sh.tmpl
        │   ├── 070-functions.sh
        │   ├── 080-mise.sh.tmpl
        │   └── paths/
        │       ├── priority.paths.sh.tmpl
        │       ├── default.paths.sh.tmpl
        │       └── custom.paths.sh.tmpl
        ├── atuin/
        │   └── config.toml         # Atuin settings
        └── mise/
            └── config.toml         # Runtime versions
```

## Inspiration

Thanks to [Drew](https://github.com/Drewtopia/dotfiles) for the modular shell architecture inspiration!

## License

Feel free to use anything from this repo for your own dotfiles.
