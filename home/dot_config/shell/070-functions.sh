# Custom Functions
# Useful shell functions

# ─────────────────────────────────────────────────────────────────────────────
# Directory Operations
# ─────────────────────────────────────────────────────────────────────────────

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Create a temporary directory and cd into it
tmpd() {
  local dir
  dir=$(mktemp -d)
  cd "$dir" || return
  echo "Created and moved to: $dir"
}

# ─────────────────────────────────────────────────────────────────────────────
# File Operations
# ─────────────────────────────────────────────────────────────────────────────

# Extract archives (supports multiple formats)
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Development Helpers
# ─────────────────────────────────────────────────────────────────────────────

# Quick HTTP server in current directory
serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

# Find and list all git repositories in current directory
repos() {
  find . -type d -name ".git" -exec dirname {} \; 2>/dev/null | sort
}

# ─────────────────────────────────────────────────────────────────────────────
# System Information
# ─────────────────────────────────────────────────────────────────────────────

# Quick system info
sysinfo() {
  echo "Hostname: $(hostname)"
  echo "OS: $(uname -s) $(uname -r)"
  echo "Shell: $SHELL"
  echo "Uptime: $(uptime | sed 's/.*up //' | sed 's/, [0-9]* user.*//')"
}
