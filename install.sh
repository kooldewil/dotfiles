#!/bin/bash

# Aki's Mac Setup Script
# Run this on a fresh Mac to install everything

set -e  # Exit on error

echo "🚀 Starting Mac setup..."
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only!"
    exit 1
fi

# Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏸️  Press any key after Command Line Tools installation completes..."
    read -n 1 -s
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
fi

# Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# Install chezmoi if not already installed
if ! command -v chezmoi &> /dev/null; then
    echo "📋 Installing chezmoi..."
    brew install chezmoi
else
    echo "✅ chezmoi already installed"
fi

# Initialize chezmoi with dotfiles
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    echo "⬇️  Initializing dotfiles with chezmoi..."
    chezmoi init kooldewil
else
    echo "✅ Dotfiles already initialized"
fi

# Apply dotfiles
echo "🔧 Applying dotfiles..."
chezmoi apply

# Install Homebrew packages from Brewfile
if [ -f "$HOME/.local/share/chezmoi/Brewfile" ]; then
    echo "📦 Installing Homebrew packages..."
    brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"
else
    echo "⚠️  Brewfile not found, skipping package installation"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "📌 Next steps:"
echo "1. Sign in to 1Password"
echo "2. Sign in to Raycast and sync settings"
echo "3. Import BetterTouchTool presets"
echo "4. Import Stream Deck profiles"
echo "5. Configure any app-specific settings"
echo ""
echo "💡 Tip: Run 'chezmoi edit ~/.zshrc' to customize your shell"
echo ""
