# Dotfiles Quick Reference

## Daily Usage

### Update dotfiles on your machine
```bash
chezmoi update
```

### Edit a config file
```bash
chezmoi edit ~/.zshrc
# or
chezmoi edit --apply ~/.zshrc  # Apply immediately after editing
```

### See what would change
```bash
chezmoi diff
```

### Apply changes
```bash
chezmoi apply
```

### Add a new file to dotfiles
```bash
chezmoi add ~/.config/someapp/config.yml
```

## Repository Management

### Navigate to your dotfiles repo
```bash
chezmoi cd
```

### Commit and push changes
```bash
chezmoi cd
git add .
git commit -m "Update configurations"
git push
```

### Pull latest changes
```bash
chezmoi cd
git pull
cd -
chezmoi apply
```

## Shell Tools

### Powerlevel10k
```bash
p10k configure      # Customize prompt appearance
```

### zoxide (smarter cd)
```bash
z <partial-path>    # Jump to frequently used directory
zi                  # Interactive directory picker
```

### atuin (enhanced history)
```bash
atuin search        # Search command history
atuin stats         # View history statistics
atuin login         # Sync history across machines (optional)
```

### mise (runtime manager)
```bash
mise install        # Install runtimes from config
mise use node@20    # Use specific version in current dir
mise ls             # List installed runtimes
mise doctor         # Check for issues
```

## Homebrew Management

### Update all packages
```bash
brew update && brew upgrade && brew cleanup
# or use the alias:
brewup
```

### Add a new package to Brewfile
```bash
chezmoi edit --apply Brewfile
# Add your package, save, then run:
brew bundle --file=~/.local/share/chezmoi/Brewfile
```

### Clean up unused packages
```bash
brew bundle cleanup --file=~/.local/share/chezmoi/Brewfile
```

## Useful Commands

### Reload shell configuration
```bash
source ~/.zshrc
# or use the alias:
reload
```

### Check what chezmoi manages
```bash
chezmoi managed
```

### Forget a file (stop managing it)
```bash
chezmoi forget ~/.someconfig
```

### Re-run external dependency downloads
```bash
chezmoi apply --refresh-externals
```

## Setup New Mac

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi and dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kooldewil

# 3. Install Homebrew packages
brew bundle --file=~/.local/share/chezmoi/Brewfile

# 4. Create chezmoi config (if prompted for template vars)
# Edit ~/.config/chezmoi/chezmoi.toml with your settings

# 5. Apply dotfiles
chezmoi apply

# 6. Configure Powerlevel10k
p10k configure

# 7. Install runtimes
mise install
```

## Troubleshooting

### Reset a file to dotfiles version
```bash
chezmoi apply --force ~/.zshrc
```

### See what chezmoi will do
```bash
chezmoi apply --dry-run --verbose
```

### Re-initialize from GitHub
```bash
chezmoi init --apply kooldewil
```

### Template variable errors
If you see errors about missing template variables, ensure your config exists:
```bash
cat ~/.config/chezmoi/chezmoi.toml
```

### Refresh external dependencies
```bash
chezmoi apply --refresh-externals
```
