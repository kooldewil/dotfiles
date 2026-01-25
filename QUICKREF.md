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

## Setup New Mac

Just run:
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kooldewil
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
