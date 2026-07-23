#!/usr/bin/env bash
# Standard health check for a time-windowed Jump Desktop Connect service log.
# Usage: check-window.sh <windowed-log-file>
#
# Produces counts for the known failure signatures (see REFERENCE.md for what
# each one means and its current fix status), plus a ranked breakdown of all
# ERROR lines in the window so anything new/unrecognized still surfaces.

set -uo pipefail

F="${1:?Usage: check-window.sh <windowed-log-file>}"

if [ ! -f "$F" ]; then
  echo "File not found: $F" >&2
  exit 1
fi

count() {
  # grep -c always prints a count (even "0"), but exits nonzero when that
  # count is zero - capture via command substitution rather than `||`
  # fallback, which would otherwise double-print on a legitimate zero.
  grep -cE "$1" "$F" 2>/dev/null
}

echo "=== Health check: $F ($(wc -l < "$F" | tr -d ' ') lines) ==="
echo
echo "Bandwidth-collapse (WebRTC estimator below configured min bitrate): $(count 'below configured min bitrate')"
echo "Frame-timestamp drops (NTP dup / non-monotonic):                    $(count 'Same/old NTP timestamp|not monotonically increasing')"
echo "DXGI capture failures (access lost / DD failure / init dx / dup):   $(count 'Could not acquire next texture|DD failure|Could not initialize dx|Could not create duplicate output')"
echo "Audio overflow (WASAPI overflow / RtAudio error):                   $(count 'Overflow detected|RtAudioError')"
echo
echo "--- GPU adapter (re)init timestamps in this window ---"
grep "Initialized adapter" "$F" | awk '{print $1, $2}' | sort -u
echo
echo "--- All ERROR lines, normalized and ranked ---"
grep "ERROR" "$F" | sed -E 's/^[0-9: -]+[0-9]+:[0-9]+ //' | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -20
