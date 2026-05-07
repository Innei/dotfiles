# Architecture & Flow

## Design

Migration has two phases: **export from old Mac** + **automated setup on new Mac**.

```
[Old Mac]                          [New Mac]
                                   
migrate.sh ──rsync──→ ~/migrate/   setup.sh
  ├─ Export live data                ├─ 00-macos-settings
  ├─ rsync config files              ├─ 01-fix-permissions
  ├─ rsync /Applications             ├─ 02-xcode-cli
  └─ rsync scripts themselves        ├─ ...
                                     └─ 16-re-auth
```

## Data Flow

1. `migrate.sh` exports live data (notification prefs, GPG keys/trust, extension lists) on old Mac, rsyncs them together with pre-built `data/` files
2. Apps in `data/rsync-apps.txt` are rsync'd from `/Applications` to `~/migrate/apps/`
3. `setup.sh` reads `data/` files to drive automated installation
4. `12-dock-restore.sh` reads `data/dock-layout.json` to restore Dock icons

## Step Dependencies

```
00 macOS Settings  (no deps, run first)
01 Fix Permissions (depends on: rsync'd ~/.ssh; GPG permissions are repaired after import)
02 Xcode CLI       (no deps, required by Homebrew)
03 Homebrew        (depends on: 02)
04 Brewfile        (depends on: 03)
05 Dotfiles        (depends on: 04, needs rcm)
06 Node.js         (no deps, but 05 should restore shell config first)
07 pnpm            (depends on: 06)
08 Global Packages (depends on: 06, 07)
09 Editor Exts     (depends on: 04, needs code CLI)
10 .pkg Apps       (depends on: 02, needs curl/xcode)
11 Install Apps    (depends on: 03 for mas, and rsync'd apps)
12 Dock Restore    (depends on: 10, 11 — all apps installed)
13 GPG Import      (depends on: 10 for GPG Suite/gpg, and data/gpg export)
14 Quarantine      (depends on: 04, 10, 11 — apps installed)
15 Notifications   (depends on: 10, 11 — app bundle ids exist)
16 Re-auth         (no deps, reminder checklist)
```

## Shared Library (lib.sh)

Every step starts with `source lib.sh`, providing:

- `info/ok/warn/fail` — colored log functions
- `step_header` — print step title
- `has <cmd>` — check if command exists
- `ensure_brew` — ensure brew is available (arm64 PATH compatible)

## setup.sh Compatibility

macOS ships bash 3.2 which lacks `declare -A`. setup.sh uses `|`-delimited string arrays with pipe parsing instead of associative arrays.
