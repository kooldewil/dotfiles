---
name: homeserver
description: Manage Shaunak's Proxmox homeserver, AdGuard Home, ASUS router, and LXC containers. Use when user asks to manage, check, update, configure, or diagnose anything on the homeserver, AdGuard, router, DNS, containers, Proxmox, or mentions CT100/miniflux/freshrss/rsshub.
---

# Homeserver

## Change discipline (read before changing anything)

AdGuard is DNS for the whole network: a bad change takes every device offline, including the one you'd use to fix it. When a step below feels skippable, flag it and let Shaunak decide instead of skipping it.

1. **Prefer the API over editing files.** AdGuard, Proxmox and the router all have one (recipes below). API changes are atomic and don't need a restart.
2. **If you must edit a service's own config file** (e.g. `AdGuardHome.yaml`), don't edit it under the running process. The service can rewrite the file on shutdown or fail to start:
   ```bash
   ssh root@192.168.50.3 'cd /opt/AdGuardHome &&
     cp -p AdGuardHome.yaml AdGuardHome.yaml.bak-$(date +%Y%m%d)-<change> &&
     systemctl stop AdGuardHome && <edit> && systemctl start AdGuardHome &&
     sleep 5 && systemctl is-active AdGuardHome'
   dig +short @192.168.50.3 www.bbc.com   # must still resolve
   ```
3. **Have the rollback ready before the change**, as one command, and make sure it doesn't depend on DNS working. Use IPs, not `.home` names:
   ```bash
   ssh root@192.168.50.3 'cd /opt/AdGuardHome && systemctl stop AdGuardHome &&
     cp -p AdGuardHome.yaml.bak-<...> AdGuardHome.yaml && systemctl start AdGuardHome'
   ```
4. **Back up before changing a container.** Use `pct snapshot VMID NAME` where snapshots work (CT 100–103). Where they don't (CT 104, bind mount), `cp -p file file.bak.pre-<change>` before editing, or `vzdump` for larger changes.
5. **After an `/etc/fstab` change on the host**, `pct stop` then `pct start` any container with a bind mount on that path (CT 104). A `pct reboot` isn't enough.
6. Read a running service's real environment with `tr "\0" "\n" < /proc/$(pgrep -of <pattern>)/environ`.

## Infrastructure

| Service | URL | IP | Credentials (1Password) |
|---------|-----|----|-------------|
| Proxmox | https://proxmox.home:8006 | 192.168.50.2 | `op://Private/Proxmox` (username `root`, realm `@pam`) |
| AdGuard Home | http://adguard.home | 192.168.50.3 | `op://Private/Adguard Home` |
| ASUS Router | http://192.168.50.1 | 192.168.50.1 | `op://Private/Asus Router` (read the lockout warning before scripting a login) |

### LXC Containers (Proxmox node: `homeserver`)

| CT | Name | IP | Purpose |
|----|------|----|---------|
| 100 | adguard | 192.168.50.3 | AdGuard Home DNS/ad-blocking |
| 101 | miniflux | 192.168.50.4 | RSS reader |
| 102 | freshrss | 192.168.50.5 | RSS reader |
| 103 | rsshub | 192.168.50.6 | RSS feed generator (port 1200) |
| 104 | timemachine | 192.168.50.7 | Samba/Time Machine share for network backups |

### Known Devices

| Device | IP | MAC | Notes |
|--------|----|-----|-------|
| Work laptop (2 NICs) | see memory | see memory | Hostname, IPs and MACs are in `~/.claude/memory/projects.md` ("Work laptop on home network"), not here, because this file is in a public repo |
| Shauns-M4-Mini | 192.168.50.142 | — | |
| Shaunaks-MBP | 192.168.50.76 | — | |

## Authentication

Credentials live in 1Password and are read at runtime with `op read` (Touch ID prompt via the desktop-app integration). Never write them to files, the skill, memory, or command output. Shell state doesn't persist between Bash calls, so set the variable in the same call that uses it.

### Proxmox API
```bash
RESPONSE=$(curl -sk -X POST "https://192.168.50.2:8006/api2/json/access/ticket" \
  --data-urlencode "username=$(op read 'op://Private/Proxmox/username')@pam" \
  --data-urlencode "password=$(op read 'op://Private/Proxmox/password')")
TICKET=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['ticket'])")
CSRF=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['CSRFPreventionToken'])")
# Use: -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF"
```
SSH (`root@192.168.50.2`, key auth) needs no password and covers most tasks via `pct`.

### ASUS Router
Verified 2026-09-29. The form must be URL-encoded like the browser sends it (`--data-urlencode`): with plain `-d`, the `=` padding in the base64 value can break the login.
```bash
# 1. Check the failed-login counter first (no login attempt). Only proceed if error_num is 0.
curl -s http://192.168.50.1/Main_Login.asp | grep -o '"error_status": [0-9]*, "last_time_lock_warning": [0-9]*, "error_num": [0-9]*'
# 2. Log in. Abort if 1Password didn't answer (Touch ID timeout), or an empty login gets sent and counted as a failure
U=$(op read 'op://Private/Asus Router/username') && P=$(op read 'op://Private/Asus Router/password') && [ -n "$U" ] && [ -n "$P" ] \
  || { echo "1Password read failed - NOT contacting router"; exit 1; }
AUTH=$(printf '%s:%s' "$U" "$P" | base64); unset U P
TOKEN=$(curl -s -D - -o /dev/null -X POST "http://192.168.50.1/login.cgi" \
  -H "Referer: http://192.168.50.1/Main_Login.asp" \
  --data-urlencode "action_wait=5" --data-urlencode "current_page=Main_Login.asp" --data-urlencode "next_page=index.asp" \
  --data-urlencode "login_authorization=$AUTH" --data-urlencode "login_captcha=" \
  | sed -n 's/.*asus_token=\([^;]*\).*/\1/p')
[ -n "$TOKEN" ] || echo "login FAILED - stop, do not retry"
# Use: -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/"
# 3. Log out when done (only one admin session is allowed at a time)
curl -s -o /dev/null -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/" http://192.168.50.1/Logout.asp
```
**Lockout danger:** the router counts failed logins. At 2 it demands a CAPTCHA (scripts can't log in), at 5 it locks for a few minutes, and at **10 it locks permanently until the router is factory reset**. A successful login resets the counter. Make **one** attempt at most, only when `error_num` is 0. If it fails, stop and ask Shaunak to log in via the browser.

After Shaunak edits a 1Password item, read it with `op read --cache=false`, because `op` can serve the old value for a short time.

### AdGuard Home
```bash
AG="$(op read 'op://Private/Adguard Home/username'):$(op read 'op://Private/Adguard Home/password')"
curl -s -u "$AG" http://192.168.50.3/control/status   # basic auth on all requests
```

## Common Tasks

The AdGuard recipes assume `AG` is set as above.

### AdGuard — check status & protection
```bash
curl -s -u "$AG" http://192.168.50.3/control/status | python3 -m json.tool
```

### AdGuard — read / replace custom filtering rules (no restart)
```bash
curl -s -u "$AG" http://192.168.50.3/control/filtering/status \
  | python3 -c "import sys,json; print('\n'.join(json.load(sys.stdin)['user_rules']))" > rules.bak.txt
# edit a copy, then send the FULL list back (it replaces all rules):
python3 -c "import sys,json; print(json.dumps({'rules': open('rules.new.txt').read().splitlines()}))" \
  | curl -s -u "$AG" -X POST http://192.168.50.3/control/filtering/set_rules \
      -H "Content-Type: application/json" -d @-
```
Keep `rules.bak.txt` in the scratchpad as the rollback.

### AdGuard — enable/disable protection
```bash
curl -s -u "$AG" -X POST http://192.168.50.3/control/protection \
  -H "Content-Type: application/json" -d '{"enabled": true, "duration": 0}'
```

### AdGuard — update filters
```bash
curl -s -u "$AG" -X POST http://192.168.50.3/control/filtering/refresh \
  -H "Content-Type: application/json" -d '{"whitelist": false}'
curl -s -u "$AG" -X POST http://192.168.50.3/control/filtering/refresh \
  -H "Content-Type: application/json" -d '{"whitelist": true}'
```

### AdGuard — update AdGuard Home itself
```bash
ssh root@192.168.50.2 'pct exec 100 -- sh -c "cd /opt/AdGuardHome && ./AdGuardHome --update"'
```
DNS takes a few seconds to answer after the restart while filters reload.

### AdGuard — add client exemption (bypass all filtering)
```bash
curl -s -u "$AG" -X POST http://192.168.50.3/control/clients/add \
  -H "Content-Type: application/json" \
  -d '{"name":"NAME","ids":["MAC1","MAC2"],"use_global_settings":false,"filtering_enabled":false,"parental_enabled":false,"safebrowsing_enabled":false,"safesearch":{"enabled":false},"use_global_blocked_services":true,"blocked_services":[],"upstreams":[],"tags":[]}'
```

### AdGuard — search the query log
The API's `/control/querylog` is the live view. The on-disk log (`/opt/AdGuardHome/data/querylog.json`, one JSON object per line) lags by up to 1000 entries (`size_memory`), so after asking Shaunak to reproduce something, poll until its last timestamp passes the time of the test.

### Proxmox — list containers
```bash
curl -sk -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF" \
  "https://192.168.50.2:8006/api2/json/nodes/homeserver/lxc" | python3 -c "
import sys,json
for c in sorted(json.load(sys.stdin)['data'], key=lambda x: x['vmid']):
    print(c['vmid'], c['name'], c['status'])"
```

### Proxmox — reboot a container
```bash
curl -sk -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF" \
  -X POST "https://192.168.50.2:8006/api2/json/nodes/homeserver/lxc/VMID/status/reboot"
```

### Proxmox — resize container disk
```bash
curl -sk -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF" \
  -X PUT "https://192.168.50.2:8006/api2/json/nodes/homeserver/lxc/VMID/resize" \
  -d "disk=rootfs&size=XG"
# Then grow the filesystem inside the container:
ssh root@192.168.50.2 "pct exec VMID -- resize2fs /dev/sda"
```

### SSH — exec command in any container
```bash
# Via Proxmox host (works for all containers)
ssh root@192.168.50.2 "pct exec VMID -- <command>"
# Direct SSH (AdGuard container only)
ssh root@192.168.50.3 "<command>"
```

### Router — get DHCP client list
```bash
curl -s -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/" \
  "http://192.168.50.1/appGet.cgi?hook=get_clientlist()"
```

### Router — read settings (nvram)
```bash
# One key per request; multiple nvram_get() hooks in one call only return the first
curl -s -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/" \
  "http://192.168.50.1/appGet.cgi?hook=nvram_get(dhcpd_dns_router)"
```
Useful keys: `dhcp_start`, `dhcp_end`, `dhcp_dns1_x`, `dhcp_dns2_x`, `dhcpd_dns_router` (advertise router as DNS: must be `0`), `dhcp_static_x` (manual assignment on/off), `dhcp_staticlist`.

### Router — set static DHCP lease
Entry format on this firmware (it has per-entry DNS, `dhcp_static_dns`): `<MAC>IP>DNS>HOSTNAME`, with each entry starting with `<`. The web UI columns are in that order: IP Address, DNS Server, Host Name. `dhcp_static_x=1` turns manual assignment on. Read the current `dhcp_staticlist` first, because the POST replaces the whole list.
```bash
curl -s -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/" \
  -X POST "http://192.168.50.1/apply.cgi" \
  --data-urlencode "action_mode=apply" --data-urlencode "action_script=restart_net" --data-urlencode "action_wait=5" \
  --data-urlencode "current_page=Advanced_DHCP_Content.asp" --data-urlencode "dhcp_static_x=1" \
  --data-urlencode "dhcp_staticlist=<AA:BB:CC:DD:EE:FF>192.168.50.X>>hostname"
```
`restart_net` briefly drops the network for every client. Tell Shaunak before running it.

## Known Config

Current state only. For when and why something changed, see `git log -p` on this file.

### Host and containers
- **Proxmox**: PVE 9.2.20, kernel 7.0.14-19-pve, Debian 13 trixie. Repo `/etc/apt/sources.list.d/proxmox.sources` (trixie, pve-no-subscription; enterprise/ceph are `.disabled`). If updates look suspiciously empty, check `apt-cache policy pve-manager`: the repo once pointed at the wrong Debian release. Always `apt-get dist-upgrade`, never plain `upgrade`.
- **Containers**: all Debian 13 trixie, update with `apt-get dist-upgrade` via `pct exec`. All have `onboot: 1`.
- **Snapshots**: `pct snapshot` works on CT 100–103 (LVM-thin). CT 104 can't be snapshotted (bind mount `mp0`), so use `vzdump 104 --mode stop --storage local --compress zstd` (rootfs only, not the TM disk).
- **SSH**: key `~/.ssh/id_ed25519` works on the Proxmox host (192.168.50.2) and CT 100 (192.168.50.3). Reach the other containers via `pct exec`.
- **Local hook**: a Claude Code hook blocks `rm -rf`, so design update steps around `mv` and new dirs.
- **Unexplained outage 2026-09-14 → 09-24**: host went down uncleanly (journal just stops). Power loss or hard hang, cause unknown.
- **Pending cleanup** (rollback points from the 2026-09-28 updates; delete after ~2026-10-05 if nothing broke): snapshots `pre_update_20260928` on CT 100–103; CT 104 vzdump on `local`; CT 101 `/root/miniflux-db-pre-2.3.3.sql.gz`; CT 102 `/root/freshrss-*-pre-1.30.0.*` + `/opt/freshrss-1.29.1-old`; CT 103 `/opt/rsshub-old-0788983ea` (2.4 GB) + `/root/rsshub-dist-0788983ea`; host `/root/pve-no-subscription.list.bookworm.bak`.

### AdGuard (CT 100)
- **Version**: v0.107.79. **Resources**: 6 GB disk, 2 GB RAM. At 512 MB it was OOM-killed, which made the UI/API hang and look like a login failure.
- **Filters** update weekly. Query log and stats are kept 30 days.
- **Clients are matched by IP, not MAC.** AdGuard can only map a MAC to a device when it is the DHCP server; here the router is, so a client keyed only by MAC never matches. Give a client its IP in `ids` too, and reserve that IP on the router. Check with `POST /control/clients/search {"clients":[{"id":"<ip>"}]}`: an empty `name` means no match.
- **iCloud Private Relay is blocked for the iPhone only**, via **Blocked services**, not custom rules. The global blocked-services list is empty. Client `Shaunak-iPhone` (ids: its MAC + `192.168.50.37`) has `use_global_blocked_services: false`, `blocked_services: ["icloud_private_relay"]`. Why: with Private Relay / "Limit IP Address Tracking" on, Safari sends ad/tracker lookups through Apple's relay, which bypasses AdGuard (BBC ads on the iPhone). Blocking it network-wide made every Mac show "Private Relay unavailable", so Shaunak chose to scope it to the iPhone. Precedence gotchas: a Blocked service can only be overridden by an `@@…$important` rule, and `check_host?client=` ignores per-client settings, so verify in the real query log instead. `@@||apple-dns.net^$important` and `@@||mask-api.icloud.com^$important` stay.
- **Work laptop**: client entry keyed by both MACs (see memory) with `use_global_settings: true`. Because it's MAC-only it never actually matches (see above), which is harmless as it only uses global settings anyway. Shaunak unblocks specific domains as issues come up rather than exempting the device.
- **Pending (2026-09-29)**: Shaunak to reserve `192.168.50.37` for the iPhone on the router (MAC `B2:C5:6D:D7:37:44`, manual assignment on) and set its Private Wi-Fi Address to Fixed. Then verify in the query log that the iPhone's `mask.icloud.com` is `FilteredBlockedService` and its BBC ad lookups are blocked, while the Macs' relay lookups are allowed. Rollback script from that session: restore global blocked services `["icloud_private_relay"]` and the old `@@||mask*.icloud.com^$important` rules.

### Apps
- **Miniflux (CT 101)**: v2.3.3 from the GitHub release `.deb` (not an apt repo). PostgreSQL DB `miniflux_db`, config `/etc/miniflux.conf`. Migrations are NOT automatic: after upgrading run `miniflux -c /etc/miniflux.conf -migrate`, then restart, or it fails with "database schema is not up to date". Health: `http://192.168.50.4:8080/healthcheck`.
- **FreshRSS (CT 102)**: v1.30.0 tarball at `/opt/freshrss` (no git), owned `www-data`, Apache + PostgreSQL DB `freshrss`, user `shaunakt`. Upgrade: extract the release into a new dir excluding `data/`, copy the old `data/` and extensions in, `chown -R www-data`, swap dirs. Check with `php cli/health.php` as www-data. Feeds refresh every 15 min via `/etc/cron.d/freshrss-actualize`. It blocks local-network feed URLs by default.
- **RSSHub (CT 103)**: git checkout of `DIYgod/RSSHub` at `/opt/rsshub`, `rsshub.service` (`node dist/index.mjs`, port 1200). Build with **pnpm via corepack**, not npm (npm crashes with `reading 'edgesOut'`): `COREPACK_ENABLE_DOWNLOAD_PROMPT=0 CI=true corepack pnpm install --frozen-lockfile && corepack pnpm run build`. Upgrade in a separate clone (`/opt/rsshub-next`), smoke-test with `PORT=1201 node dist/index.mjs`, then swap dirs and restart. The disk is 10 GB and two checkouts take about 5 GB.
- **Time Machine (CT 104)**: Sabrent 1 TB SSD attached to the host as `/dev/sdb`, ext4, mounted at `/mnt/tm-disk` (fstab by UUID), owned `100000:100000` so the unprivileged CT can write, and bind-mounted into CT 104 at `/srv/timemachine` via `mp0`. Samba shares `/srv/timemachine/backup` as `[TimeMachine]` (`vfs objects = catia fruit streams_xattr`, `fruit:time machine = yes`). One Samba user, `tm`, is shared by all Macs, and each Mac gets its own sparse bundle.

### Router
- **ASUS RT-AX95Q** (ZenWiFi AX), firmware 3.0.0.4_388_24814-g4979b32 (up to date as of 2026-07-21).
- **DHCP DNS**: DNS Server 1 = `192.168.50.3`, and **"Advertise router's IP in addition to user-specified DNS" = No**. With Yes, clients also got `192.168.50.1` as a backup DNS server, which bypasses AdGuard, so check this first if ads or blocked domains leak.
- **Web UI**: HTTPS is off. The login page redirects to `www.asusrouter.com` whenever that name resolves to the router, which only the router's own DNS does. Chrome with "Always use secure connections" then fails with ERR_CONNECTION_REFUSED; Safari falls back to plain `http` and works.
- **DHCP pool** is `192.168.50.20–254`. Everything below `.20` is kept for fixed IPs: the servers (.2–.7) set their addresses themselves, not via DHCP.
- **Manual assignment** is off (`dhcp_static_x=0`) and the list is empty; the malformed work-laptop entry was deleted 2026-09-29. Nothing relies on fixed DHCP addresses, and AdGuard identifies clients by MAC.
