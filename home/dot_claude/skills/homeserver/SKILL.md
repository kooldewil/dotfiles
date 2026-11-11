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
| 100 | adguard | 192.168.50.3 | AdGuard Home DNS/ad-blocking; also on the tailnet as `adguard` (100.64.0.3) |
| 101 | miniflux | 192.168.50.4 | RSS reader, **retired 2026-10-25**: stopped, `onboot 0`, kept in case (FreshRSS is the only RSS server) |
| 102 | freshrss | 192.168.50.5 | RSS reader |
| 103 | rsshub | 192.168.50.6 | RSS feed generator (port 1200) |
| 104 | timemachine | 192.168.50.7 | Samba/Time Machine share for network backups |
| 105 | headscale | 192.168.50.8 | Headscale (Tailscale control server), public at `https://hs.tavind.com` |
| 107 | grimmory | 192.168.50.10 | Grimmory ebook library (Docker), `http://grimmory.home:6060` |
| 106 | tailscale | 192.168.50.9 | Tailscale subnet router (`homeserver-router`, 100.64.0.1) for `192.168.50.0/24` |

### Known Devices

| Device | IP | MAC | Notes |
|--------|----|-----|-------|
| Work laptop (2 NICs) | see memory | see memory | Hostname, IPs and MACs are in `~/.claude/memory/projects.md` ("Work laptop on home network"), not here, because this file is in a public repo |
| Shauns-M4-Mini | 192.168.50.247 | — | Tailnet `macmini` 100.64.0.2; hosts T3 Code (port 3773, Network access on) |
| Shaunaks-MBP | 192.168.50.96 (DHCP, was .74) | private (rotating) | Tailnet `macbook-pro` 100.64.0.4 (accepts subnet routes). Uses a private Wi-Fi MAC, so its IP can change; find it in the router client list by name |

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

### Update round — check, then apply
Check (read-only):
- **apt**, host and each running CT: `apt-get update -qq && apt list --upgradable`.
- **AdGuard**: `POST /control/version.json` with `{"recheck_now": true}`, read `new_version`.
- **GitHub releases** (FreshRSS, Headscale, Grimmory): `gh api repos/<owner>/<repo>/releases/latest --jq .tag_name`. `gh` is authenticated; anonymous `api.github.com` calls from this IP hit the rate limit.
- **RSSHub**: in CT 103, `git fetch && git rev-list --count HEAD..origin/HEAD`.
- **Grimmory's MariaDB**: newest 11.4 LTS tag via `curl -s 'https://registry.hub.docker.com/v2/repositories/linuxserver/mariadb/tags?page_size=100&name=11.4'`.

Apply in this order, each step verified before the next:
1. `pct snapshot` every CT except 104 (one shared name, e.g. `pre_updates_YYYYMMDD`).
2. CT apt, with CT 100 (DNS) last and `dig @192.168.50.3` before and after: `pct exec N -- env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef`.
3. App updates (recipes under each app in Known Config).
4. Host `apt-get dist-upgrade` (same flags) and, for a kernel bump, reboot last: `ssh root@192.168.50.2 'nohup sh -c "sleep 2; systemctl reboot" >/dev/null 2>&1 &'`. Check `smbstatus` in CT 104 first. Every CT goes down: the host answers SSH again after ~1 min and DNS ~65 s after the reboot. If the host's apt SSH session dies mid-run (exit 137, PVE services restarting), read the result with `pveversion`, `dpkg --audit` and `apt list --upgradable`; re-run only what is left.

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

### Router — make a saved setting take effect
Verified 2026-10-15: `apply.cgi` saves the nvram values but its `action_script` did **not** restart anything (a new port forward stayed closed and a disabled WAN-admin port stayed open). After saving, trigger the restart explicitly and re-test the real behaviour (e.g. `nc -z 192.168.0.141 <port>`), not just the nvram value:
```bash
curl -s -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/" \
  -X POST http://192.168.50.1/applyapp.cgi \
  --data-urlencode "action_mode=apply" --data-urlencode "rc_service=restart_firewall;restart_httpd"
```

### Router — port forwards
`vts_enable_x=1`, `vts_rulelist` entries are `<NAME>EXTPORT>INTERNAL_IP>INTPORT>PROTO>SRCIP` (SRCIP empty = any). The list is replaced whole, so read it first. Current: `<Headscale>443>192.168.50.8>443>TCP>` (only forward).

## Known Config

Current state only. For when and why something changed, see `git log -p` on this file.

### Host and containers
- **Proxmox**: PVE 9.2.26, kernel 7.0.14-28-pve, Debian 13 trixie. Repo `/etc/apt/sources.list.d/proxmox.sources` (trixie, pve-no-subscription; enterprise/ceph are `.disabled`). If updates look suspiciously empty, check `apt-cache policy pve-manager`: the repo once pointed at the wrong Debian release. Always `apt-get dist-upgrade`, never plain `upgrade`.
- **Containers**: all Debian 13 trixie, update with `apt-get dist-upgrade` via `pct exec`. All have `onboot: 1` except CT 101 (Miniflux, retired). `systemctl is-system-running` = `degraded` on CT 105–107 comes from `wtmpdb-rotate.timer` (unit not found), a harmless Debian 13 leftover; check `systemctl --failed` for anything else.
- **Snapshots**: `pct snapshot` works on every CT except 104 (LVM-thin; on CT 107 it covers the books volume too). CT 104 can't be snapshotted (bind mount `mp0`), so use `vzdump 104 --mode stop --storage local --compress zstd` (rootfs only, not the TM disk).
- **SSH**: key `~/.ssh/id_ed25519` works on the Proxmox host (192.168.50.2) and CT 100 (192.168.50.3). Reach the other containers via `pct exec`.
  - That key lives in 1Password, which auto-locks when the unattended Mac mini idles, so SSH fails with "agent refused operation". On the Mac mini, a dedicated file key `~/.ssh/id_ed25519_homeserver` (comment `macmini-homeserver-agents`, no passphrase) is used instead via a `Host 192.168.50.2 proxmox.home 192.168.50.3 adguard.home 100.64.0.3` block in `~/.ssh/config.local` (`IdentityAgent none`). Server side it's restricted with `from="192.168.50.0/24,100.64.0.0/10"`. Added 2026-10-25. Revoke by deleting its `authorized_keys` line on both hosts.
- **Local hook (dcg)**: inspects the remote command inside `ssh`/`pct exec` and blocks `rm -rf` outside literal `/tmp`, plus any `mv` whose source or destination is a system path (`/opt`, `/etc`, `/usr`, `/var`, home), in-place renames included. Prepare new trees in `/tmp`, then put the whole dir swap in one command; when it's blocked, ask Shaunak to run the `dcg allow-once <id>` it prints and retry that exact command. Recursive deletes go to Shaunak as commands to run.
- **Unexplained outage 2026-09-14 → 09-24**: host went down uncleanly (journal just stops). Power loss or hard hang, cause unknown.
- **Planned power cut 2026-11-11** (electrician): everything came back on its own. Router and mesh settings persisted, all `onboot` CTs started, the TM SSD remounted, Headscale and FreshRSS answered at once, Grimmory ~2.5 min after host boot. Check order after a cut: ping router/modem/nodes, `dig @192.168.50.3`, `pct list`, app health.
- **Cleanup 2026-10-15**: the 2026-09-28 rollback points are gone (snapshots on CT 100–103, CT 104 vzdump, DB dumps, host apt `.bak`); `pct fstrim 100` reclaimed 3.2 GB (thin-pool `Data%` overstates usage until trimmed — check `df` inside the CT). Old app dirs `/opt/freshrss-1.29.1-old` (CT 102), `/opt/rsshub-old-0788983ea` + `/root/rsshub-dist-0788983ea` (CT 103) were handed to Shaunak to delete (recursive deletes are hook-blocked). Today's snapshots `pre_tailscale_20261015` (CT 100), `headscale_configured` (CT 105), `subnet_router_up` (CT 106): delete after ~2026-10-29 if nothing broke.
- **Pending cleanup from the 2026-11-06 update round** (delete ~2026-11-13 if nothing broke): snapshots `pre_updates_20261106` on CT 100, 102, 103, 105, 106, 107; on CT 102 `/opt/freshrss-1.30.0-old` and the stray nested copy `/opt/freshrss/data/data`; on CT 107 `/opt/grimmory/compose.yaml.bak-20261106`. Also on CT 102: snapshots `pre_bbc_unicity_force_20261108` and `pre_news_sport_merge_20261108` (delete ~2026-11-15).
- **Tailnet devices**: homeserver-router 100.64.0.1, macmini .2, adguard .3, macbook-pro .4, iphone .5, ipad .6. iOS registers as `localhost`; rename with `headscale nodes rename -i ID NAME`. Interactive registration: `headscale auth register --auth-id hskey-authreq-... --user shaunak`.

### AdGuard (CT 100)
- **Version**: v0.107.80. **Resources**: 6 GB disk, 2 GB RAM. At 512 MB it was OOM-killed, which made the UI/API hang and look like a login failure.
- **Filters** update weekly. Query log and stats are kept 30 days.
- **Clients are matched by IP, not MAC.** AdGuard can only map a MAC to a device when it is the DHCP server; here the router is, so a client keyed only by MAC never matches. Give a client its IP in `ids` too, and reserve that IP on the router. Check with `POST /control/clients/search {"clients":[{"id":"<ip>"}]}`: an empty `name` means no match.
- **iCloud Private Relay is exempted network-wide** (reverted 2026-09-29). A same-day attempt scoped the block to just the iPhone — client `Shaunak-iPhone` (ids: its MAC + `192.168.50.37`) with `use_global_blocked_services: false`, `blocked_services: ["icloud_private_relay"]` — to stop Safari's ad/tracker lookups from bypassing AdGuard via Private Relay (BBC ads on the iPhone) without breaking Private Relay on the Macs (a network-wide block made every Mac show "Private Relay unavailable"). Shaunak rolled that back the same evening: global `blocked_services: ["icloud_private_relay"]` is restored, and so are `@@||mask.icloud.com^$important` / `@@||mask-h2.icloud.com^$important` (alongside the standing `@@||apple-dns.net^$important` and `@@||mask-api.icloud.com^$important`) — those `$important` allow rules override the service block, so Private Relay works everywhere again. Trade-off: the BBC-ads-bypass issue on the iPhone is back too. If re-attempting the per-client scoping, see git history around commit `830fe09` for the exact config; precedence gotchas noted there still apply (a Blocked service can only be overridden by an `@@…$important` rule, and `check_host?client=` ignores per-client settings — verify in the real query log instead).
- **Work laptop**: client entry keyed by both MACs (see memory) with `use_global_settings: true`. Because it's MAC-only it never actually matches (see above), which is harmless as it only uses global settings anyway. Shaunak unblocks specific domains as issues come up rather than exempting the device.

### Apps
- **Miniflux (CT 101)**: v2.3.3 from the GitHub release `.deb` (not an apt repo). PostgreSQL DB `miniflux_db`, config `/etc/miniflux.conf`. Migrations are NOT automatic: after upgrading run `miniflux -c /etc/miniflux.conf -migrate`, then restart, or it fails with "database schema is not up to date". Health: `http://192.168.50.4:8080/healthcheck`.
- **FreshRSS (CT 102)**: the single RSS sync server since 2026-10-25. Clients are FeedFlow on iPhone, iPad and Mac via the Google Reader API (`http://freshrss.home/api/greader.php`, user `shaunakt`, FreshRSS *API* password); News Explorer (iCloud sync, Mac mini as fetcher) was removed. v1.30.4 tarball at `/opt/freshrss` (no git), owned `www-data`, Apache + PostgreSQL DB `freshrss`, user `shaunakt` (tables `shaunakt_feed`, `shaunakt_entry`). No custom extensions. Feeds refresh every 15 min via `/etc/cron.d/freshrss-actualize`. It blocks local-network feed URLs by default.
  - **Upgrade**: releases have no assets, so use the source tarball `https://github.com/FreshRSS/FreshRSS/archive/refs/tags/<ver>.tar.gz`. Extract in `/tmp` (gives `FreshRSS-<ver>/`), then merge the live data into the tarball's skeleton `data/` with `cp -a /opt/freshrss/data/. /tmp/FreshRSS-<ver>/data/` (the trailing `/.` copies contents; `cp -a old/data new/data` nests it as `data/data/`). `chown -R www-data:www-data`, then swap in one command: `mv /opt/freshrss /opt/freshrss-<old>-old && mv /tmp/FreshRSS-<ver> /opt/freshrss` (dcg needs an allow-once). CT 102 has no `rsync`.
  - **Removing a feed**: GReader API `subscription/edit` with `ac=unsubscribe&s=feed/<id>` (needs the API password via `op read`, which prompts on the Mac mini). Equivalent without credentials: `DELETE FROM shaunakt_feed WHERE id=<id>` (articles cascade via FK), after checking `grep f_<id> /opt/freshrss/data/users/shaunakt/config.php` for saved queries; FreshRSS's own delete only adds those and a custom favicon. **The Age** was removed 2026-11-08: paywalled, Shaunak doesn't subscribe, the feed carries only ~125-character teasers and the page served to non-subscribers has no article body, so FeedFlow's reader view showed only page chrome.
  - **Verify an upgrade through the API**: unauthenticated `curl 'http://localhost/api/greader.php/accounts/ClientLogin?Email=x&Passwd=x'` returns 401 when healthy and 503 when `data/config.php` is missing. `cli/health.php` exits 0 even with the user data missing, so it can't confirm an upgrade. Then confirm `SELECT COUNT(*) FROM shaunakt_feed` (94 on 2026-11-06).
  - **BBC feeds (News 186, Sport 201) use "Article unicity criteria" = Link with Force on** (feed attributes `unicityCriteria: link`, `unicityCriteriaForced: true`). BBC appends a rotating `#0`–`#9` to each item's GUID, so with the default ID criterion every refresh re-imported the same story (~790 duplicates on 2026-10-25).
  - **Always set Force with a non-default criterion.** Unforced, FreshRSS degrades the criterion by itself (`Feed::loadGuids`) whenever more than ~5% of one fetch's GUIDs repeat: `link` → `sha1:link_published` → `sha1:link_published_title`. BBC Sport repeats links in one fetch (e.g. the bare `https://www.bbc.co.uk/sport`), so on 2026-10-27 both BBC feeds degraded and every BBC time/title update came in as a new article (141 copies cleaned up 2026-11-08). With Force on, a repeated link only sets the feed's warning icon (`error`); refresh timing is unchanged. If duplicates return, check `attributes::jsonb->>'unicityCriteria'` first.
  - **Changing a feed's criterion or deduping**: old rows no longer match the new ID, so set `guid = link` on the kept rows or everything re-imports. Dedupe per `(id_feed, link)`: keep `max(id)` with `is_read`/`is_favorite` = max over the copies, delete the rest, then recompute `"cache_nbEntries"`/`"cache_nbUnreads"`, all in one transaction. Do DB edits right after a `:00/:15/:30/:45` run (a run takes ~15–40 s) with none running (`ps -eo args | grep '[a]ctualize_script'`; an unbracketed `pgrep -f` matches its own command): a concurrent refresh saves its stale copy of the feed attributes back over yours. Snapshots `pre_bbc_dedupe_20261025`, `pre_bbc_unicity_force_20261108`.
  - **Macworld (169) and AppleInsider (164)** also use Link (not forced; they've never degraded), plus per-feed `mark_updated_article_unread: true`: they re-publish updated articles under the same URL, which now resurfaces the existing copy instead of adding one.
  - **Cross-feed duplicates (News ↔ Sport)**: since 2026-11-08 ABC Sport and BBC Sport sit in the **News** category (id 18) with ABC Top Stories and BBC News; Shaunak reads FeedFlow's unified timeline, not sections. Category attribute `read_when_same_guid_in_category: 500`: a new article whose GUID is already among the category's newest 500 entries arrives read, so the first copy of a story stays unread and later copies arrive read. GUIDs matched for all 85 shared stories over 14 days (titles for only ~88%); the longest gap between copies was 8 h at ~230 entries/day. The rule counts read entries too, so keep auto-read filters off these four feeds: a filter-read first copy would hide the later copy as well (why the old `inurl:/sport/` and `#Sport` filters were removed; the `#Sport` one missed untagged ABC stories). The empty `Sport` category (21) is Shaunak's to delete in the UI. Snapshot `pre_news_sport_merge_20261108`.
- **RSSHub (CT 103)**: git checkout of `DIYgod/RSSHub` at `/opt/rsshub`, `rsshub.service` (`node dist/index.mjs`, port 1200). Build with **pnpm via corepack**, not npm (npm crashes with `reading 'edgesOut'`): `COREPACK_ENABLE_DOWNLOAD_PROMPT=0 CI=true corepack pnpm install --frozen-lockfile && corepack pnpm run build`. Upgrade in a separate clone (`/opt/rsshub-next`), smoke-test with `PORT=1201 node dist/index.mjs`, then swap dirs and restart. The disk is 10 GB and two checkouts take about 5 GB. Node comes from the NodeSource apt repo; restart `rsshub` after a Node upgrade so it runs the new binary. Idle as of 2026-11-06 (no FreshRSS feed uses it, no requests since 2026-09-28); Shaunak keeps it running for future generated feeds.
- **Time Machine (CT 104)**: Sabrent 1 TB SSD (RTL9210 NVMe enclosure) attached to the host as `/dev/sdb` on a **blue USB 3.2 Gen 2 port** (10 Gbps, `uas` driver, ~680 MB/s read; it was on a USB 2.0 port at 480 Mbps until 2026-10-15 — check `lsusb -t` if backups get slow), ext4, mounted at `/mnt/tm-disk` (fstab by UUID), owned `100000:100000` so the unprivileged CT can write, and bind-mounted into CT 104 at `/srv/timemachine` via `mp0`. Samba shares `/srv/timemachine/backup` as `[TimeMachine]` (`vfs objects = catia fruit streams_xattr`, `fruit:time machine = yes`). One Samba user, `tm`, is shared by all Macs, and each Mac gets its own sparse bundle.

### Router
- **ASUS RT-AX95Q** (ZenWiFi AX), firmware 3.0.0.4_388_24911-g2055148 on both nodes (installed 2026-11-10 from the ASUS app). Check per-node versions with `appGet.cgi?hook=get_cfg_clientlist()` (`fwver`).
- **Double NAT behind the Optus modem**: the ASUS WAN is `192.168.0.141` on the Optus Sagemcom F@ST 5366 (`192.168.0.1`, NBN FTTP), which holds the public IP (dynamic, not CGNAT). The modem stays because it carries the landline (VoIP, Line1). Modem has DMZ → `192.168.0.141` and a DHCP reservation pinning the ASUS to that address, so inbound traffic reaches the ASUS; forward ports on the ASUS only. Don't touch the modem's Voice or WAN settings. Its Wi-Fi is **off** since 2026-11-10 (Wi-Fi → Basic → Enable Wireless Access; login in 1Password item `192.168.0.1`): on ch 36/80 MHz at −42 dBm it shared the mesh's 5 GHz channel block and pushed MacBook pings to the router to ~500 ms. If Wi-Fi gets laggy again, check it hasn't come back on (e.g. after an Optus firmware push or modem reset).
- **Mesh**: two XT8 nodes, Hallway (main router) and Office (DHCP, `192.168.50.142` after the 2026-11-10 reboot, was `.143`; Ethernet backhaul, `re_path` 1). Smart Connect on, one SSID for all bands.
  - **5 GHz-1** (`wl1`, client band) only allows **ch 36–48** on this model, and every 80 MHz option there is one block, so changing its channel can't avoid an interferer in that block. Both nodes currently sit on ch 44.
  - **5 GHz-2** (`wl2`, ch 149–165, on 149/80) is a client band since 2026-11-10: **Ethernet Backhaul Mode** is on (AiMesh → System Settings; its confirm dialog keeps Tri-Band Smart Connect and the main SSID), so `wl2_ssid` is the main SSID and `wl2_closed=0`. Before that it was the hidden wireless backhaul `<main SSID>_dwb`. Most iPhones/iPads/Macs moved to it at once. With this mode on, a node whose Ethernet cable fails loses its uplink (no wireless fallback). `wl_ssid` still reads `_dwb`; that's a stale generic key.
  - **Roaming** has three layers. (1) Apple devices roam on their own only below about −70 dBm (iPhone) / −75 dBm (Mac), so on its own the MacBook sticks to the far node. (2) Roaming Assistant (Wireless → Professional, `wlN_user_rssi`) is on at −70 dBm on all three bands (5 GHz-2 added 2026-11-10): it deauths a client below the threshold so it rejoins the node it hears best; it covers the Mac's −70 to −75 gap. Syslog: `roamast: ... disconnect weak signal strength station [mac]`. (3) `bsd` sends 802.11v BSS transition requests (`Sending act Frame ... transition target`), which Apple devices honour, so they often move before being kicked.
  - **802.11r is off**, so each roam is a full reconnect (up to ~1 s): a call may freeze briefly between nodes. Enable it only if call drops bother Shaunak; it can stop older 2.4 GHz IoT devices (e.g. the Roborock) from joining.
  - **Ping-pong check**: count kicks per MAC with `grep 'disconnect weak signal' syslog | grep -o '\[[0-9a-f:]*\]' | sort | uniq -c`, and map MACs to names via `get_clientlist()`. 184 kicks were logged before the 2026-11-10 changes, one iPhone ~10 times in 45 min (a spot weak to both nodes). If one device keeps bouncing, try −75 on that band (devices then hold a weak node longer) before anything else.
  - **MacBook baseline** after the 2026-11-10 fixes: ping to the router mostly 4–6 ms, 0% loss, with occasional 70–115 ms spikes. Those are typical macOS AWDL (AirDrop/Handoff) and scan off-channel time, not the mesh; confirm with `sudo ifconfig awdl0 down` for one test run, then `up`.
  - **Sticky client after a reboot**: after the 2026-11-11 power cut an iPhone carried from the hallway into the office stayed on Hallway at −79 dBm for 8+ min without a Roaming Assistant kick (`roamast` had restarted at boot). Toggling Wi-Fi in Settings moved it to Office and restored speed. Try that first before changing roaming settings.
- **Firmware upgrade gotcha**: an AiMesh upgrade that stalls stays marked as running, and every retry logs `rc_service: skip the event: stop_upgrade;start_webs_upgrade 1` (in the syslog via `appGet.cgi?hook=nvram_dump("syslog.log","")`). On 2026-11-10 the first two app attempts did that; a later one from the app went through. If it stays stuck, reboot the router before retrying.
- **1Password**: use the item **Asus Router**. The two `192.168.50.1 (admin)` items (2024) hold an old password but are the ones Safari autofill offers for this address, which caused failed web logins on 2026-11-10.
- **DDNS**: ASUS DDNS (`*.asuscomm.com`, name in the router UI under WAN → DDNS) with `ddns_realip_x=1`, so it registers the real public IP despite the double NAT. HTTPS cert option left on Auto (Let's Encrypt there would claim port 80). Point custom names at it with a CNAME. `hs.tavind.com` is a CNAME to it (DNS for tavind.com is at Fastmail, Settings → Domains → Customize DNS; leave the mail records alone).
- **Internet exposure**: only TCP 443 → CT 105 (Headscale). "Web Access from WAN" (`misc_http_x`) is **off** (it was on, admin on WAN port 8080, which the DMZ would have exposed). Keep it off; reach the router over the tailnet instead.

### Headscale (CT 105)
- v0.29.7 from the GitHub `.deb`, config `/etc/headscale/config.yaml` (original at `config.yaml.orig`). Listens on `0.0.0.0:443` directly, own Let's Encrypt cert via **TLS-ALPN-01** (port 443 only, no port 80). Cert cache `/var/lib/headscale/cache`. Health: `https://hs.tavind.com/health`; inside the CT use `curl --resolve hs.tavind.com:443:127.0.0.1 https://hs.tavind.com/health` (plain `localhost` fails the TLS handshake, as the cert only answers that SNI).
- **Upgrade**: `env DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::=--force-confold ./headscale_<ver>_linux_amd64.deb`, then `systemctl restart headscale`. `--force-confold` keeps the edited `config.yaml`; without it dpkg stops at the conffile prompt and leaves the package `iU`, which `dpkg --force-confdef --force-confold --configure headscale` finishes.
- Every TLS handshake with SNI `hs.tavind.com` while there's no valid cert triggers an ACME attempt, and Let's Encrypt allows only ~5 failed validations/hour. Test reachability with `nc -z`, not curl, until the path is confirmed.
- From the LAN the public IP doesn't loop back through the Optus modem; test the forward via the ASUS WAN IP: `curl --resolve hs.tavind.com:443:192.168.0.141 https://hs.tavind.com/health`.
- MagicDNS base domain `tail.tavind.com`. User `shaunak`. CLI: `pct exec 105 -- headscale ...`.
- Client DNS (`dns.nameservers.global`) is `100.64.0.3` then `192.168.50.3`: the same AdGuard reached two ways (its own tailnet IP, and via the subnet router). Both filter, so nothing leaks; either path can fail without breaking remote DNS. AdGuard's log shows tailnet devices by their `100.64.0.x` IP (via the subnet-router path they appear as `192.168.50.9`). Config backups `config.yaml.bak-20261015-pre-adguard` (Cloudflare) and `-pre-adguard-tailnet` (LAN IP only).
- Snapshot `headscale_configured` = clean config before any clients.
- **Hairpin**: the Optus modem doesn't loop the public IP back, so at home `hs.tavind.com` must resolve locally. AdGuard has a rewrite `hs.tavind.com → 192.168.50.8` (for LAN clients); CT 106 has it in `/etc/hosts` instead, because servers use the router (`192.168.50.1`) for DNS, not AdGuard, and remote access shouldn't depend on AdGuard.
- New devices: `headscale preauthkeys create --user 1 --expiration 1h` (single use), or interactive login from the client then `headscale nodes register`. Subnet routes need `headscale nodes approve-routes --identifier N --routes CIDR`.

### Backups (Proxmox → Time Machine SSD)
- Storage `tm-backup` = `/mnt/tm-disk/proxmox-backups` (dir, `is_mountpoint /mnt/tm-disk` so it goes offline instead of filling the root disk if the SSD is unplugged; `prune-backups keep-last=4`).
- Job: **Sundays 03:00**, CT 100, 105, 106, 107, snapshot mode (no downtime), zstd. First run 2026-10-15 took 59 s (AdGuard 0.5 GB, Headscale 0.3 GB, subnet router 0.35 GB, Grimmory 1.1 GB incl. books + MariaDB). CT 107's `mp0` books volume is included (`backup=1`); MariaDB is crash-consistent (snapshot), which InnoDB recovers from.
- Not in the job: CT 101–103 (RSS apps) and CT 104 (its data *is* the Time Machine disk; snapshot mode impossible with the bind mount).
- To unplug the SSD safely: check `smbstatus` in CT 104 and disk idle, `pct stop 104`, `umount /mnt/tm-disk`; after: `mount /mnt/tm-disk`, `pct start 104`.
- Restore: `pct restore <newid> /mnt/tm-disk/proxmox-backups/dump/vzdump-lxc-<id>-....tar.zst --storage local-lvm`.

### Grimmory (CT 107)
- Docker (29.x, from download.docker.com trixie repo) in an unprivileged CT with `nesting=1,keyctl=1`; 2 cores / 3 GB. Compose project `/opt/grimmory` (`compose.yaml`): `ghcr.io/grimmory-tools/grimmory:v3.5.0` + `lscr.io/linuxserver/mariadb:11.4.12`, both **pinned** — Grimmory releases often and was dropped from community-scripts as "unstable". MariaDB stays on the 11.4 LTS line (linuxserver's `latest` is 11.8.x, a major jump). Update: snapshot, bump tags, `docker compose pull && docker compose up -d`; for a DB-only bump `docker compose up -d --no-deps mariadb` recreates just the DB (healthy in ~6 s, the app stays up). An apt upgrade of `docker-ce` restarts dockerd, and both containers come back on their own.
- Books on a separate 100 GB volume `mp0` → `/srv/books` (`library/` = Grimmory's `/books`, `bookdrop/`, `staging/` for SSD imports). Local disk, so default `DISK_TYPE` (LOCAL) — Drew's NFS caveats don't apply. `lost+found` there is host-owned; chown only the subfolders.
- DB passwords are generated on the server in `/opt/grimmory/grimmory.conf` (mode 600, loaded via `env_file`), deliberately not `.env` (Claude hooks block `.env`/`secret` paths) and not in 1Password. Never print it. 1Password `Grimmory` = web admin login only.
- Bookdrop: copy batches into `/srv/books/staging/` first, then `mv` into `bookdrop/` — files streamed straight in were sometimes seen mid-write as "directories" and skipped until **Rescan**. Applied fetched metadata can be a wrong match for niche/self-published books (test: "The Habit Guide" became Glen Van Peski's book, ISBN included) — only apply fetched metadata where the fetched title matches the file's own. Genres from Goodreads are noisy (adds "Audiobook").
- Not exposed to the internet; reached over the LAN/tailnet via AdGuard rewrite `grimmory.home → 192.168.50.10`. Snapshot `grimmory_installed` = empty, before admin setup.

### Tailscale in AdGuard (CT 100)
- `--dev0 /dev/net/tun` (adding it needs a CT stop/start: ~13 s DNS outage on 2026-10-15). Joined with `--accept-dns=false --accept-routes=false --hostname adguard`, so AdGuard's own upstream lookups are unchanged. `hs.tavind.com` pinned in `/etc/hosts`. AdGuard binds `0.0.0.0` and `allowed_clients` is empty, so it answers on the tailnet IP with no config change. Snapshot `pre_tailscale_20261015` = before this.

### Tailscale subnet router (CT 106)
- Tailscale from `pkgs.tailscale.com` (trixie repo), `--dev0 /dev/net/tun`, IP forwarding in `/etc/sysctl.d/99-tailscale.conf`. Joined with `--advertise-routes=192.168.50.0/24 --accept-dns=false --hostname homeserver-router`; route approved. The "UDP GRO forwarding" warning is expected (ethtool can't be changed in an unprivileged CT) and only limits peak throughput.
- Snapshot `subnet_router_up`.
- **DHCP DNS**: DNS Server 1 = `192.168.50.3`, and **"Advertise router's IP in addition to user-specified DNS" = No**. With Yes, clients also got `192.168.50.1` as a backup DNS server, which bypasses AdGuard, so check this first if ads or blocked domains leak.
- **Web UI**: HTTPS is off. The login page redirects to `www.asusrouter.com` whenever that name resolves to the router, which only the router's own DNS does. Chrome with "Always use secure connections" then fails with ERR_CONNECTION_REFUSED; Safari falls back to plain `http` and works.
- **DHCP pool** is `192.168.50.20–254`. Everything below `.20` is kept for fixed IPs: the servers (.2–.7) set their addresses themselves, not via DHCP.
- **Manual assignment** is off (`dhcp_static_x=0`) and the list is empty; the malformed work-laptop entry was deleted 2026-09-29. Nothing relies on fixed DHCP addresses, and AdGuard identifies clients by MAC.
