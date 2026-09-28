---
name: homeserver
description: Manage Shaunak's Proxmox homeserver, AdGuard Home, ASUS router, and LXC containers. Use when user asks to manage, check, update, configure, or diagnose anything on the homeserver, AdGuard, router, DNS, containers, Proxmox, or mentions CT100/miniflux/freshrss/rsshub.
---

# Homeserver

## Infrastructure

| Service | URL | IP | Credentials |
|---------|-----|----|-------------|
| Proxmox | https://proxmox.home:8006 | 192.168.50.2 | See memory: homeserver-credentials |
| AdGuard Home | http://adguard.home | 192.168.50.3 | See memory: homeserver-credentials |
| ASUS Router | http://192.168.50.1 | 192.168.50.1 | See memory: homeserver-credentials |

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

### Proxmox API
```bash
RESPONSE=$(curl -sk -X POST "https://192.168.50.2:8006/api2/json/access/ticket" \
  -d "username=root@pam&password=PASSWORD")
TICKET=$(echo $RESPONSE | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['ticket'])")
CSRF=$(echo $RESPONSE | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['CSRFPreventionToken'])")
# Use: -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF"
```

### ASUS Router
```bash
TOKEN=$(curl -s -X POST "http://192.168.50.1/login.cgi" \
  -H "Referer: http://192.168.50.1/Main_Login.asp" \
  -d "group_id=&action_mode=&action_script=&action_wait=5&current_page=Main_Login.asp&next_page=index.asp&login_authorization=$(echo -n 'admin:PASSWORD' | base64)" \
  -D /dev/stderr 2>&1 1>/dev/null | grep -oP 'asus_token=\K[^;]+')
# Use: -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/"
```

### AdGuard Home
```bash
# Basic auth on all requests
curl -u "USERNAME:PASSWORD" http://192.168.50.3/control/status
```

## Common Tasks

### AdGuard — check status & protection
```bash
curl -s -u "USER:PASS" http://192.168.50.3/control/status | python3 -m json.tool
```

### AdGuard — enable/disable protection
```bash
curl -s -u "USER:PASS" -X POST http://192.168.50.3/control/protection \
  -H "Content-Type: application/json" -d '{"enabled": true, "duration": 0}'
```

### AdGuard — update filters
```bash
curl -s -u "USER:PASS" -X POST http://192.168.50.3/control/filtering/refresh \
  -H "Content-Type: application/json" -d '{"whitelist": false}'
curl -s -u "USER:PASS" -X POST http://192.168.50.3/control/filtering/refresh \
  -H "Content-Type: application/json" -d '{"whitelist": true}'
```

### AdGuard — trigger self-update
```bash
curl -s -u "USER:PASS" http://192.168.50.3/control/version.json?recheck=true
curl -s -u "USER:PASS" -X POST http://192.168.50.3/control/update
```

### AdGuard — add client exemption (bypass all filtering)
```bash
curl -s -u "USER:PASS" -X POST http://192.168.50.3/control/clients/add \
  -H "Content-Type: application/json" \
  -d '{"name":"NAME","ids":["MAC1","MAC2"],"use_global_settings":false,"filtering_enabled":false,"parental_enabled":false,"safebrowsing_enabled":false,"safesearch":{"enabled":false},"use_global_blocked_services":true,"blocked_services":[],"upstreams":[],"tags":[]}'
```

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
# After resize, SSH to Proxmox host and run resize2fs inside the container:
# ssh root@192.168.50.2 "pct exec VMID -- resize2fs /dev/sda"
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

### Router — set static DHCP lease
```bash
# Format: <MAC>HOSTNAME>IP>
curl -s -b "asus_token=$TOKEN" -H "Referer: http://192.168.50.1/" \
  -X POST "http://192.168.50.1/apply.cgi" \
  -d "action_mode=apply&action_script=restart_net&action_wait=5&current_page=Advanced_DHCP_Content.asp&dhcp_staticlist=ENCODED_LIST"
```

## Known Config

- **AdGuard filter update schedule**: weekly (168h)
- **AdGuard query log retention**: 30 days
- **AdGuard stats retention**: 30 days
- **AdGuard version**: v0.107.79 (updated 2026-09-28 via `pct exec 100 -- sh -c "cd /opt/AdGuardHome && ./AdGuardHome --update"` — CLI updater, no API creds needed; DNS takes a few seconds to answer after restart while filters reload)
- **Proxmox**: PVE 9.2.20, kernel 7.0.14-19-pve (2026-09-28). Debian 13 trixie. Repo: `/etc/apt/sources.list.d/proxmox.sources` (trixie, pve-no-subscription); enterprise/ceph sources are `.disabled`. Before 2026-09-28 the repo wrongly pointed at `bookworm` (PVE 8), so PVE packages silently got no updates — check `apt-cache policy pve-manager` if updates look suspiciously empty. Always use `apt-get dist-upgrade` on the host, never plain `upgrade`.
- **Container OS**: all CTs are Debian 13 trixie; update with `apt-get dist-upgrade` via `pct exec`
- **Container onboot**: all CTs (100–104) have `onboot: 1` (CT 103 was missing it until 2026-09-28)
- **Snapshots before updates**: `pct snapshot VMID NAME` works for CT 100–103 (LVM-thin). CT 104 can't be snapshotted (bind mount `mp0`) — use `vzdump 104 --mode stop --storage local --compress zstd` instead (backs up rootfs only, not the TM disk)
- **Outage 2026-09-14 → 09-24**: host went down uncleanly (journal just stops, no shutdown messages); cause unknown (power loss or hard hang). Came back after a manual restart.
- **Miniflux (CT 101)**: installed from GitHub release `.deb` (`miniflux_X.Y.Z_amd64.deb`, not an apt repo). Version 2.3.3 (2026-09-28). PostgreSQL DB `miniflux_db`; config `/etc/miniflux.conf`. Migrations are NOT automatic — after upgrading run `miniflux -c /etc/miniflux.conf -migrate` then restart, or the service fails with "database schema is not up to date". Health: `http://192.168.50.4:8080/healthcheck`
- **FreshRSS (CT 102)**: tarball install at `/opt/freshrss` (no git), owned `www-data`, Apache + PostgreSQL DB `freshrss`, user `shaunakt`. Version 1.30.0 (2026-09-28). Upgrade: extract release into a new dir excluding `data/`, copy old `data/` + extensions in, `chown -R www-data`, swap dirs. Check with `php cli/health.php` as www-data. Feeds refresh via `/etc/cron.d/freshrss-actualize` every 15 min. Since 1.30.0 it blocks local-network feed URLs by default.
- **RSSHub (CT 103)**: git checkout of `DIYgod/RSSHub` at `/opt/rsshub`, run by `rsshub.service` (`node dist/index.mjs`, port 1200). Build with **pnpm via corepack**, not npm (npm crashes with `Cannot read properties of null (reading 'edgesOut')`): `COREPACK_ENABLE_DOWNLOAD_PROMPT=0 CI=true corepack pnpm install --frozen-lockfile && corepack pnpm run build`. Safe upgrade pattern: build in a separate clone (`/opt/rsshub-next`), smoke-test with `PORT=1201 node dist/index.mjs`, then swap dirs and restart. CT disk is 10 GB — watch space (two checkouts ≈ 5 GB).
- **Pending cleanup (rollback points from 2026-09-28 updates, safe to delete after ~2026-10-05 if nothing broke)**: snapshots `pre_update_20260928` on CT 100–103; CT 104 vzdump on `local` storage; CT 101 `/root/miniflux-db-pre-2.3.3.sql.gz`; CT 102 `/root/freshrss-*-pre-1.30.0.*` + `/opt/freshrss-1.29.1-old`; CT 103 `/opt/rsshub-old-0788983ea` (2.4 GB) + `/root/rsshub-dist-0788983ea`; host `/root/pve-no-subscription.list.bookworm.bak`
- **Local hook**: a Claude Code hook blocks `rm -rf` commands — design update steps around `mv`/new dirs instead
- **ASUS router**: RT-AX95Q, firmware 3.0.0.4_388_24814-g4979b32 — confirmed up to date via ASUS update-check API on 2026-07-21
- **Work laptop filtering**: changed 2026-07-29 — no longer a full bypass. Client entry keyed by both of its MACs (see memory) with `use_global_settings: true`, so it's now filtered by the same global blocklists as every other device. (History: briefly had `filtering_enabled: false` as a blanket bypass, and briefly also had its two static IPs added to `ids` to work around an AdGuard rDNS auto-client matching bug; both of those were reverted on 2026-07-29 at Shaunak's request. He now wants to see what gets blocked and unblock specific domains/rules manually as issues come up, rather than exempting the whole device.)
- **CT 100 disk**: 6 GB (expanded from 2 GB on 2026-07-06)
- **CT 100 memory**: 2 GB (raised from 512 MB on 2026-07-15 — AdGuardHome was being repeatedly OOM-killed by the memory cgroup at 512 MB, which caused the web UI/API to hang and look like a login failure)
- **SSH access**: key (`~/.ssh/id_ed25519`) works on Proxmox host (`192.168.50.2`) and AdGuard container (`192.168.50.3`); reach other containers via `pct exec` through Proxmox host
- **Time Machine SSD**: Sabrent SB-2130-1TB, was direct-attached to the Mac Mini, moved to the homeserver on 2026-07-21. Physically attached to the Proxmox host as `/dev/sdb`, reformatted from APFS to a single ext4 partition (old local backup history was wiped intentionally), mounted at `/mnt/tm-disk` on the host (in `/etc/fstab` by UUID), owned by `100000:100000` so CT104 (unprivileged) can write to it, bind-mounted into CT104 at `/srv/timemachine` via `mp0`. Samba in CT104 shares `/srv/timemachine/backup` as `[TimeMachine]` with `vfs objects = catia fruit streams_xattr` and `fruit:time machine = yes` (Apple's Time Machine-over-SMB extensions). Single Samba user `tm` is shared across all Macs backing up to it — Time Machine automatically creates a separate sparse bundle per machine, so this supports multiple Macs (Mac Mini + MBP M1) without conflict.
