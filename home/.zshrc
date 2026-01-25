# Aki's .zshrc
# Shell configuration for zsh

# Enable colors
autoload -U colors && colors

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Enable completion
autoload -U compinit && compinit

# Homebrew setup (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Syntax highlighting (if installed via Homebrew)
if [[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Auto-suggestions (if installed via Homebrew)
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Better ls with eza (if installed)
if command -v eza &> /dev/null; then
  alias ls='eza --icons'
  alias ll='eza -l --icons'
  alias la='eza -la --icons'
  alias tree='eza --tree --icons'
fi

# Better cat with bat (if installed)
if command -v bat &> /dev/null; then
  alias cat='bat --style=plain'
fi

# Common aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias brewup='brew update && brew upgrade && brew cleanup'
alias zshconfig='${EDITOR:-nano} ~/.zshrc'
alias reload='source ~/.zshrc'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# Chezmoi aliases
alias cm='chezmoi'
alias cma='chezmoi apply'
alias cme='chezmoi edit'
alias cmcd='chezmoi cd'

# Better prompt
PROMPT='%F{cyan}%~%f %F{green}❯%f '

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Show/hide hidden files in Finder
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
  
  # Empty trash
  alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash'
fi

# Custom functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# fzf configuration (if installed)
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi
