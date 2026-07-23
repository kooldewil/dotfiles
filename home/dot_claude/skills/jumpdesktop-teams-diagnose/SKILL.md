---
name: jumpdesktop-teams-diagnose
description: Diagnose Jump Desktop + Microsoft Teams call quality issues (video stuttering/freezing, choppy frames, audio echo) on Shaunak's M4 Mac Mini to Surface Laptop 5 remote work setup. Use when Shaunak reports a bad Teams call over Jump Desktop, asks to check Jump Desktop / Connect diagnostic logs, mentions video freezing, stutter, or echo on a call, or wants a post-call diagnosis.
---

# Jump Desktop + Teams Call Diagnostics

Evidence-based diagnosis for call-quality problems on Shaunak's Mac Mini (client) to Surface Laptop 5 (host, Intel Iris Xe iGPU only, no discrete GPU) Jump Desktop Fluid connection. Three known root causes were already found (and partially fixed) this way — see [REFERENCE.md](REFERENCE.md) for the full history and exact log-pattern catalogue.

**Don't assume a past cause is still THE cause.** Re-derive from fresh evidence every time — the way "joined Teams twice" was a plausible theory but got directly disproven by actually checking Task Manager, rather than left as an assumption. Report what the evidence shows, including when it doesn't match any known pattern.

## 0. Detect mode

- **Running on the Mac**: logs are OneDrive-synced (read-only) at `~/Library/CloudStorage/OneDrive-VictorianElectoralCommission/JumpConnectDiagLogs/{agent,service}/`.
- **Running on the Windows laptop directly**: same log content lives locally — find the real path if not already known (check `%APPDATA%` and `%PROGRAMDATA%` for a Jump Desktop/Connect folder). You also have live system access here — prefer it over log archaeology:
  - Process/CPU state: Task Manager or `Get-Process`
  - GPU driver version: Device Manager → Intel Iris Xe Graphics → Driver tab, or `Get-CimInstance Win32_VideoController`
  - GPU crash/TDR history: Event Viewer → Windows Logs → System, filter for `Display` / `nvlddmkm`/`igfx` sources
  - Teams GPU-accel state: check `desktop-config.json` / `app_settings.json` (paths in REFERENCE.md) for `"disableGpu"`
  - Live audio devices: Settings → Sound → Volume mixer

## 1. Scope the time window

Get the call's approximate start/end time from Shaunak, or infer it. Service logs are huge (1-2MB+/day) — always narrow to a window before grepping, never grep the whole file:

```bash
awk -F'[: ]' '{ts=$2":"$3":"$4; if (ts>="HH:MM:SS" && ts<="HH:MM:SS") print}' Service_YYYY_MM_DD.log > /tmp/window.log
```

If the exact call time is unknown, run `scripts/find-sessions.sh <logfile>` first — it lists capture-pipeline (re)init timestamps, which cluster around session/call starts.

## 2. Run the standard health check on that window

```bash
scripts/check-window.sh /tmp/window.log
```

Reports counts for: bandwidth-collapse events, frame-timestamp-drop warnings, DXGI capture failures, audio overflow events, and a ranked breakdown of all ERROR lines. Zero across the board = healthy window. See REFERENCE.md if you need the raw grep patterns (e.g. running by hand on Windows/PowerShell).

## 3. Map findings to known causes

Full detail and current fix status in REFERENCE.md — summary:

| Evidence pattern | Likely cause | Status |
|---|---|---|
| Bandwidth-collapse + frame-drops, no DXGI burst | GPU contention (Jump Desktop capture vs Teams decode) via Teams hardware acceleration | Fixed 2026-07-23 — verify still disabled |
| Tight burst of DXGI failures + adapter re-inits within seconds | Desktop Duplication bug on Intel Iris Xe | Open — driver was stale (16/04/2025); Surface driver update attempted, verify outcome |
| Audio overflow / pipeline restarts around an echo complaint | Audio thread contention desyncing Teams AEC reference | Leading theory, not confirmed |
| Isolated DXGI failures at a steady low background rate (~every 15min) regardless of load | Likely benign background capture/thumbnail cycle | Not the cause of an active-call symptom on its own |
| Doesn't match any row above | Something new | Say so explicitly — don't force-fit |

## 4. Report

State what you checked, the concrete counts/excerpts (not vague summaries), which known cause(s) the evidence supports or rules out, and a concrete next step. **Update REFERENCE.md** with anything new learned this run (a new error pattern, a fix confirmed working or not, a theory confirmed or disproven, a driver/version change) so the next run starts smarter than this one.
