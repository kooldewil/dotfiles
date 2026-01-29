# History Configuration
# Shell history settings for zsh

# History file location
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

# Create history directory if it doesn't exist
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# History size
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicates when new ones added
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt HIST_VERIFY            # Show command before executing from history
setopt EXTENDED_HISTORY       # Save timestamp and duration
setopt INC_APPEND_HISTORY     # Add commands immediately to history
