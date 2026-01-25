# Aki's Dotfiles

My personal dotfiles for macOS, managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

Install on a new Mac:

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kooldewil
```

## What's Included

- **Homebrew packages**: All my essential apps and tools via Brewfile
- **Shell configuration**: zsh with custom aliases and functions
- **Git configuration**: Global Git settings and aliases
- **macOS defaults**: System preferences and settings
- **App configs**: Raycast, BetterTouchTool, and other app settings

## Manual Setup

Some things still need manual configuration:

- **Stream Deck**: Import profiles from backup
- **BetterTouchTool**: Import presets after installation
- **Raycast**: Sign in and sync settings
- **1Password**: Sign in to enable integrations

## Updating

To update your dotfiles on an existing machine:

```bash
chezmoi update
```

## Structure

```
.
├── README.md                 # This file
├── Brewfile                  # Homebrew packages
├── install.sh               # Installation script
├── .chezmoiroot             # Chezmoi root directory marker
└── home/                    # Files that go in $HOME
    ├── .zshrc
    ├── .gitconfig
    └── .config/             # XDG config directory
```

## Inspiration

Thanks to [Drew](https://github.com/Drewtopia/dotfiles) for the inspiration to finally organize my dotfiles!

## License

Feel free to use anything from this repo for your own dotfiles.
