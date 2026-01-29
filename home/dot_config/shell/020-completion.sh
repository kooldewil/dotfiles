# Completion Configuration
# Zsh completion system setup

# Enable completion
autoload -Uz compinit

# Cache completions for faster startup
if [[ -n ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump(#qN.mh+24) ]]; then
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
else
  compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
fi

# Create cache directory if it doesn't exist
[[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]] || mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# Completion styling
zstyle ':completion:*' menu select                      # Use menu selection
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Use LS colors
zstyle ':completion:*' verbose yes                      # Verbose completion
zstyle ':completion:*:descriptions' format '%B%d%b'     # Description format
zstyle ':completion:*:warnings' format 'No matches for: %d'

# Group completions by type
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# Cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
