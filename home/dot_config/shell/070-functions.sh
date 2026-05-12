# Custom shell functions

# ── Directory ─────────────────────────────────────────────────────────────────

# Create directory and cd into it
mkcd() {
  [[ -z "$1" ]] && { echo "Usage: mkcd <dir>"; return 1; }
  mkdir -p "$1" && cd "$1"
}

# Create a temporary directory and cd into it
tmpd() {
  local dir
  dir=$(mktemp -d) && cd "$dir" && echo "$dir"
}

# Go up N directories (default: 1)
up() {
  local n="${1:-1}"
  local path=""
  for (( i=0; i<n; i++ )); do path="../$path"; done
  cd "${path:-.}"
}

# cd then ls
cl() {
  cd "${1:-.}" && ls
}

# ── Files ─────────────────────────────────────────────────────────────────────

# Extract archives (auto-detects format)
extract() {
  [[ -z "$1" ]] && { echo "Usage: extract <file>"; return 1; }
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)  tar xjf "$1"     ;;
      *.tar.gz)   tar xzf "$1"     ;;
      *.tar.xz)   tar xJf "$1"     ;;
      *.tar.zst)  tar --zstd -xf "$1" ;;
      *.bz2)      bunzip2 "$1"     ;;
      *.gz)       gunzip "$1"      ;;
      *.rar)      unrar x "$1"     ;;
      *.tar)      tar xf "$1"      ;;
      *.tbz2)     tar xjf "$1"     ;;
      *.tgz)      tar xzf "$1"     ;;
      *.zip)      unzip "$1"       ;;
      *.zst)      zstd -d "$1"     ;;
      *.Z)        uncompress "$1"  ;;
      *.7z)       7z x "$1"        ;;
      *)          echo "Don't know how to extract '$1'" ;;
    esac
  else
    echo "'$1' is not a file"
  fi
}

# ── Development ───────────────────────────────────────────────────────────────

# Quick HTTP server — binds to 0.0.0.0 so LAN devices can reach it
serve() {
  local port="${1:-8000}"
  local ip
  ip=$(ipconfig getifaddr en0 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')
  echo "Serving on http://localhost:${port}  (LAN: http://${ip}:${port})"
  python3 -m http.server "$port" --bind 0.0.0.0
}

# List all git repos under current directory
repos() {
  find . -type d -name ".git" -exec dirname {} \; 2>/dev/null | sort
}
