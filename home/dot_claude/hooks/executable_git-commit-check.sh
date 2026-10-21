#!/usr/bin/env bash
# Checks Claude's `git commit` calls (adapted from Drewtopia/dotfiles' git-commit-precheck).
#   pre  (PreToolUse Bash):  gitleaks scan of staged files; exit 2 blocks the commit.
#   post (PostToolUse Bash): commit-check on the commit git just made (Conventional
#        Commits, no AI attribution); exit 2 tells Claude to amend it.
# Reading the message back from git avoids parsing -m / heredoc quoting in the command.
# Each check is skipped when its tool isn't installed.

set -uo pipefail

MODE="${1:-pre}"
INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[[ -z "$COMMAND" ]] && exit 0

if ! printf '%s' "$COMMAND" | grep -qE '(^|[^a-zA-Z])git( -[cC] [^ ]+)* commit( |$)'; then
    exit 0
fi

# Follow the command's own `cd` or `git -C` so the right repo is checked. No eval: the
# command text is untrusted, so `~` is expanded by parameter substitution.
TARGET=$(printf '%s' "$COMMAND" \
    | grep -oE '(^|&&|;)[[:space:]]*cd[[:space:]]+[^&;|]+|git[[:space:]]+-C[[:space:]]+[^ ]+' \
    | tail -1 | sed -E 's/^.*(cd|-C)[[:space:]]+//; s/[[:space:]]+$//')
if [[ -n "$TARGET" ]]; then
    TARGET="${TARGET%\"}"; TARGET="${TARGET#\"}"
    TARGET="${TARGET%\'}"; TARGET="${TARGET#\'}"
    TARGET="${TARGET/#\~/$HOME}"
    [[ -d "$TARGET" ]] && cd "$TARGET" || true
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$REPO_ROOT" || exit 0

if [[ "$MODE" == "pre" ]]; then
    git diff --cached --quiet && exit 0
    command -v gitleaks >/dev/null 2>&1 || exit 0
    if ! gitleaks git --staged --redact --no-banner --log-level warn . >&2 2>&1; then
        echo "" >&2
        echo "BLOCKED: gitleaks found secrets in staged files." >&2
        echo "Review with \`gitleaks git --staged -v\`, unstage or remove the secrets, then retry." >&2
        exit 2
    fi
    exit 0
fi

# post: only judge a commit that this command just made.
command -v commit-check >/dev/null 2>&1 || exit 0
COMMITTED=$(git log -1 --format=%ct HEAD 2>/dev/null) || exit 0
(( $(date +%s) - COMMITTED > 120 )) && exit 0

# commit-check has no global config search path: pass ours unless the repo has its own.
CONFIG=(--config "$HOME/.config/commit-check/cchk.toml")
[[ -f "${CONFIG[1]}" ]] || CONFIG=()
for f in cchk.toml commit-check.toml .github/cchk.toml .github/commit-check.toml; do
    [[ -f "$f" ]] && { CONFIG=(); break; }
done

if ! OUTPUT=$(commit-check "${CONFIG[@]}" -m --no-banner --rev HEAD 2>&1); then
    echo "Commit $(git rev-parse --short HEAD) breaks the commit message policy:" >&2
    echo "$OUTPUT" >&2
    echo "" >&2
    echo "Fix it with \`git commit --amend -m \"<type>(<scope>): <description>\"\` before pushing." >&2
    exit 2
fi
exit 0
