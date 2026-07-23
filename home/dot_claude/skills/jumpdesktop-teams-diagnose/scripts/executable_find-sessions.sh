#!/usr/bin/env bash
# Locate likely session/call start times in a Jump Desktop Connect service log,
# for when the exact call time isn't known and needs to be discovered first.
# Usage: find-sessions.sh <full-day-logfile>
#
# GPU capture (re)initialization is a reasonable proxy for session starts -
# it clusters tightly at the start of a real connection, versus the sparser
# ~15min background rate seen when idle. Also reports any full client-connect
# markers if present, for cross-checking.

set -uo pipefail

F="${1:?Usage: find-sessions.sh <logfile>}"

if [ ! -f "$F" ]; then
  echo "File not found: $F" >&2
  exit 1
fi

echo "=== GPU adapter (re)init timestamps (session-start proxy) ==="
grep "Initialized adapter" "$F" | awk '{print $1, $2}' | sort -u

echo
echo "=== Explicit client/session markers (if present) ==="
grep -E "Starting new client|Starting with arguments|Connect Version:" "$F" | awk '{print $1, $2, $0}' | sed -E 's/^[0-9-]+ [0-9:]+ //' | sort -u
