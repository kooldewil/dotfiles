# Reference: Jump Desktop + Teams Diagnostic History

Setup: M4 Mac Mini (client) <-> Microsoft Surface Laptop 5, VEC (Victorian Electoral Commission)-managed, Intel Iris Xe integrated graphics only, no discrete GPU. Both ends on Ethernet, Jump Desktop Connect (Fluid / Fluid 2.0 codec), latest beta channel. Investigation started 2026-07-23.

## Root cause 1: Video stuttering/freezing (2fps instead of up to 144fps) — FIXED 2026-07-23

**Symptom:** Jump Desktop stats overlay shows Frames stuck near 2fps (Max Frames 144fps), Bandwidth ~0 kbyte/s despite Target Bitrate ~19Mbit/s, but Connection/Network/Protocol/Ping/Packet Loss all look perfect (Direct, Ethernet->Ethernet, UDP->UDP, 0ms, 0.0%).

**Root cause:** Intel Iris Xe (the laptop's only GPU) is contended between Jump Desktop's own screen capture/encode (DXGI Desktop Duplication + Fluid 2.0 encoder) and Microsoft Teams' own video decode/render, especially during calls with camera + screen share. The contention causes frame delivery jitter at the capture source. WebRTC's send-side bandwidth estimator (delay-based GCC algorithm) misreads that local jitter as network congestion and collapses the bitrate to ~300kbps and frame rate to ~2fps — even though the actual network is fine.

**Log evidence that confirmed it:**
- `Estimated available bandwidth 300 kbps is below configured min bitrate 1134400 bps` (from `send_side_bandwidth_estimation.cc:640`) — recurring throughout an affected call window.
- `Same/old NTP timestamp (...) for incoming frame. Dropping.` (`video_stream_encoder.cc:1603`) and `Incoming frame timestamp is not monotonically increasing` (`frame_cadence_adapter.cc:1023`) — 360+ in a single ~23min affected session.
- Day-to-day variance (0 to 618 occurrences/day of the bandwidth-collapse line) correlated with how much video-call/GPU load happened that day, not a constant network condition — ruling out a real network cause.
- GPU adapter confirmed as `Intel(R) Iris(R) Xe Graphics` via every `Initialized adapter:` log line — no discrete GPU present.

**Fix applied:** Disable Microsoft Teams' GPU hardware acceleration. New Teams (WebView2-based) removed the UI toggle for this entirely — no checkbox exists in Settings anymore. Workaround used:
```
setx WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS "--disable-gpu"
```
then fully quit Teams (check Task Manager for a lingering `ms-teams.exe` background process) and relaunch.

Alternative/fallback method if the env var doesn't stick: edit the Teams config file directly and set `"disableGpu": true` under `appPreferenceSettings`. Path depends on install type:
- New Teams (MSIX): `%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\app_settings.json`
- Classic/per-machine install: `%APPDATA%\Microsoft\Teams\desktop-config.json`

**Verification (confirmed working):** Before/after log comparison on a live test call and a real 20-min multi-person call showed the bandwidth-collapse line and frame-drop warnings both went to **zero**, and fps recovered from 2fps to 28-32fps (still short of the 144fps ceiling, but smooth/watchable). Re-verify this is still in effect on future runs — don't assume it's permanently applied (e.g. after a Teams update, profile reset, or new machine).

**Secondary mitigation also applied:** Jump Desktop's own encode load was reduced via **Remote -> Framerate -> 30fps** in the Jump Desktop client menu (while connected). Note: Jump Desktop's "Image Quality" stat (Very High / High / etc.) is **not** a manual setting — it's fully automatic/adaptive based on measured bandwidth, so don't suggest changing it directly; the actual manual lever is the Framerate menu.

## Root cause 2: DXGI Desktop Duplication capture failures — OPEN, driver update attempted

**Symptom:** Bursts of capture-interface errors, sometimes causing a few seconds of real, visible freeze that self-recovers.

**Error signatures (from `service/Service_*.log`, tagged `[rtc_sc ...]`):**
```
Could not acquire next texture - access lost
Could not acquire next texture: 0x-7785ffff
DD failure, falling back
Could not initialize dx
Could not create duplicate output for display (output0/1): ... Intel(R) Iris(R) Xe Graphics (LUID: ...)
```

**Two distinct rate regimes observed:**
1. **Background/idle rate**: ~every 15 minutes, round the clock, even at 2-3am with no one connected and no active call — e.g. 92-618 occurrences/day across 07/17-07/21. This appears to be a periodic background capture/thumbnail-refresh cycle, largely independent of load. A handful of isolated hits like this across a whole day is not, by itself, evidence of an active-call problem.
2. **Burst rate during heavy load**: many of the same errors within a few seconds, combined with multiple `Initialized adapter: Intel(R) Iris(R) Xe Graphics` re-init lines clustered together (e.g. 4 re-inits within 5 seconds). This correlates with real, visible freezes and system-wide sluggishness reported by Shaunak ("everything was running slow"). Seen during a heavy call (multiple cameras + screen share) even *after* the Teams GPU-accel fix (root cause 1) was applied and confirmed working — so this is a genuinely separate bug, not a residual symptom of root cause 1.

**Note on 0-event days:** a day showing zero occurrences of either error is not proof the bug is fixed — check whether there was actually an active session that day (`grep -c "Starting new client"` or similar) first. One day (07/22) showed 0 events simply because nobody connected at all that day, not because anything was resolved.

**Driver status as of 2026-07-23:**
- Installed: Intel Iris Xe driver dated **16/04/2025**, version **32.0.101.6737**, digitally signed by "Microsoft Windows Hardware Compatibility Publisher" (i.e. delivered via Windows Update / OEM channel, not a raw Intel installer).
- Windows Update ("Search automatically for drivers") reported nothing newer.
- Intel has shipped newer point releases since (e.g. 32.0.101.7076 Sept 2025, .7080 Nov 2025, .7088 mid-2026) but these are generic Intel driver builds.
- **This is a Surface Laptop 5 — do not install generic Intel driver installers** (Intel Graphics Command Center / Intel Driver & Support Assistant). Surface ships OEM-customized drivers; a generic Intel driver can overwrite those customizations and cause new instability. Evidence this already happened once: "Intel(R) Graphics Software & Drivers" and "Intel® Graphics Software" apps were found already installed (dated 8/07/2025) despite Shaunak believing he'd uninstalled them — and yet the actual kernel driver never moved past 16/04/2025, suggesting either the generic installer silently failed to replace the OEM driver on this locked-down machine, or corporate policy blocked it.
- **Correct channel**: official Surface Laptop 5 driver/firmware `.msi` bundle from Microsoft's own Download Center: `microsoft.com/en-us/download/details.aspx?id=104679`. A December 2025 bundle was confirmed to exist (newer than the installed April 2025 driver) as of this session.
- If even the official Surface bundle shows nothing newer than what's installed, that's a sign VEC's device management (Intune/WSUS) is deliberately holding the driver back — treat as an IT ticket, not something to route around locally.
- **Action pending as of last session**: Shaunak was downloading the official Surface Laptop 5 `.msi` bundle. Next run of this skill should check whether the driver date/version actually changed (Device Manager -> Intel Iris Xe Graphics -> Driver tab) and whether the DXGI failure burst rate during heavy calls has improved.

**Unresolved side-note:** Device Manager also showed a **"Parsec Virtual Display Adapter"** installed alongside the Iris Xe adapter. Parsec is an unrelated remote-desktop/streaming tool. Never established whether this is actively used, unused/leftover, or contributing any load/conflict to the GPU's display pipeline — worth asking about if this area needs revisiting.

## Root cause 3 (candidate, unconfirmed): Audio echo reported by other call participants

**Symptom:** Other participants on a call complained of hearing an echo "from" Shaunak's device; Shaunak was put on mute.

**Ruled out:** "Joined the Teams meeting twice" (duplicate instance). Task Manager showed only **one** Microsoft Teams process tree (main app + one WebView2 child). The two separate "Microsoft Teams" entries seen in Windows Volume Mixer are normal — new Teams registers separate audio sessions (app shell vs. WebView2-hosted call UI) from a single process; this is not evidence of a duplicate join.

**Confirmed correct (not the cause):** Windows Volume Mixer showed System Output = `CABLE Input (VB-Audio Virtual Cable)` and Input = `Microphone (Elgato Wave:3)` — this is the intended routing (Teams audio -> virtual cable -> Jump Desktop capture -> Mac speakers).

**Leading theory, not confirmed:** the same Iris Xe/CPU contention responsible for root cause 1 also stalls the *audio* capture thread during heavy calls. Evidence: `Overflow detected` errors (from `audio_cap_rtaudio`, WASAPI capture buffer overflow) and full audio-pipeline stop/restart events (`Stopping capture` / `Starting capture for device:` pairs seconds apart) were both observed clustered at specific timestamps during the echo-affected call — 25 overflow events and 2 restart clusters (11:28:03-13, 12:13:37-39) in that ~90min window. Theory: this desyncs Teams' internal echo-cancellation reference signal, letting normally-cancelled acoustic leakage through as audible echo, without requiring an actual live physical speaker in the room.

**Still open / never conclusively resolved:** whether a physical speaker was actually audible in the room as a contributing or compounding factor. Shaunak was physically at the desk with the Elgato Wave:3 (a room-based desk mic, not a headset) during the affected call — inherently more echo-prone than a headset if any physical speaker (built-in Surface speakers, either external Dell monitor's speakers, or the Arctis Nova Pro headphones sitting unworn) was live nearby. Never got a direct answer on whether audio was actually audible from a physical speaker at the time.

**Audio device inventory on this laptop** (from RTAudio enumeration in the service logs):
- Outputs: `CABLE Input (VB-Audio Virtual Cable)` (system default), `Speakers (Jump Desktop Virtual Speaker)`, `Surface Omnisonic Speakers`, `DELL S2721DGF`, `DELL S3422DWG` (external monitor speakers), `Headphones (Elgato Wave:3)`, `Headphones (Arctis Nova Pro Wireless)`.
- Inputs: `Microphone (Elgato Wave:3)` (default), `Microphone (Logitech BRIO)`, `CABLE Output (VB-Audio Virtual Cable)`, `Surface Stereo Microphones`, `Microphone (Arctis Nova Pro Wireless)`.
- Device IDs shift on re-enumeration (not stable across restarts) — always match by **Name**, not ID, when reading these log lines.

**Next steps if this recurs:** check Teams' own Settings -> Devices -> Speaker (Teams can pick a device independent of the Windows system default — confirm it's `CABLE Input`, not a physical speaker); check Windows Sound Control Panel -> Recording -> Elgato Wave:3 -> Properties -> Listen tab for "Listen to this device" being enabled (a direct digital echo path if so); and directly ask Shaunak whether he actually heard call audio out of a physical speaker at the time, to separate the acoustic-leak theory from the AEC-desync theory.

## Diagnostic log source reference

**Location (Mac side, OneDrive-synced, read-only):**
`~/Library/CloudStorage/OneDrive-VictorianElectoralCommission/JumpConnectDiagLogs/`
- `agent/Agent_YYYY_MM_DD.log` (+ old `Wizard_*.log`) — thin, connection/auth lifecycle only (session start/stop, "Interactive auth request cancelled", "Partner connection closed", `Connect Version:` lines). Rarely useful for the actual video/audio pipeline, but good for confirming installed Connect version and rough session timing.
- `service/Service_YYYY_MM_DD.log` — the useful one. Detailed logs from the Windows host's capture/encode/RTC service. Files are large (1-2MB+, tens of thousands of lines per busy day).

**Location (Windows side, if running Claude Code directly on the laptop):** not yet confirmed — check `%APPDATA%` and `%PROGRAMDATA%` for a Jump Desktop / Jump Desktop Connect folder; update this file once found.

**Key grep patterns (service log):**

| Pattern | Meaning |
|---|---|
| `below configured min bitrate` (grep the full line for "Estimated available bandwidth") | WebRTC bandwidth-estimator collapse — root cause 1 indicator. Zero = healthy. |
| `Same/old NTP timestamp` , `not monotonically increasing` | Frame-drop/timestamp irregularity at capture source, correlates with pipeline jitter. |
| `Could not acquire next texture`, `access lost`, `DD failure, falling back`, `Could not initialize dx`, `Could not create duplicate output for display` | DXGI Desktop Duplication failures — root cause 2. Isolated hits at ~15min spacing = likely background/benign; tight burst of several within seconds = real problem. |
| `Overflow detected` (from `audio_cap_rtaudio`), `RtAudioError` | Audio capture buffer overflow/timing issue — relevant to root cause 3. |
| `Starting capture for device:` / `Device N: Name:...` enumeration lines | Shows current default playback/recording devices — confirm routing matches expectations (see device inventory above). |
| `Initialized adapter:` | Confirms which GPU is doing capture/encode. Expect `Intel(R) Iris(R) Xe Graphics`. Multiple clustered within seconds = pipeline restart/re-init, worth investigating what triggered it. |
| `Connect Version:` | Installed Jump Desktop Connect version. Was `10.15.6.0` as of 2026-07-23. Check `https://changelog.jumpdesktop.com/` for newer releases and whether notes mention Fluid 2.0 codec bugs, DXGI/capture bugs, or the "different refresh rate" lag bug (this laptop drives 3440x1440@100Hz + 2560x1440@144Hz simultaneously — mismatched refresh rates across displays was the trigger for a previously-fixed lag bug, resolved in 10.15.6 RC2). |

**Always window the log before grepping** — never grep a whole day's file blind:
```bash
awk -F'[: ]' '{ts=$2":"$3":"$4; if (ts>="HH:MM:SS" && ts<="HH:MM:SS") print}' Service_YYYY_MM_DD.log > /tmp/window.log
```

## Network / AdGuard note (checked, likely not the cause)

Shaunak's homeserver runs AdGuard Home (192.168.50.3) — see the `homeserver` skill for infrastructure details. The work laptop's two MACs (real NIC `a0:4a:5e:dd:82:a1` + Global Secure Access virtual NIC `00:a5:54:a2:cd:3f`) are configured as a full filtering exemption (`filtering_enabled: false`).

**Known bug found:** this exemption doesn't reliably apply. Confirmed via AdGuard query log: a DNS query for `teams.events.data.microsoft.com` from the laptop's IP (192.168.50.48) was blocked by the HaGeZi Pro blocklist (returned `0.0.0.0`) despite the exemption, because AdGuard matched the query to an auto-discovered IP-based client entry (rDNS name `VEC-k7TCwd64YY9`) rather than the MAC-keyed persistent client entry. Root cause likely: AdGuard's container network setup can't reliably resolve source MAC for this device, so MAC-based persistent-client matching silently fails and falls through to global filtering rules.

**Assessment:** real misconfiguration, but only confirmed to affect a Teams *telemetry* domain, not the media/RTP path — unlikely to be the cause of video/audio call-quality symptoms. Worth a quick sanity check (`curl -u "user:pass" http://192.168.50.3/control/querylog?search=<domain>` for a suspected blocked domain) if network-side causes are suspected again, but shouldn't be the first thing checked.

**Not yet fixed:** consider switching the persistent client's `ids` to the laptop's IPs (192.168.50.48 / 192.168.50.33) instead of/alongside MACs, since IP-based matching is what's actually being evaluated. Ask before making this change (it's a shared homeserver config).
