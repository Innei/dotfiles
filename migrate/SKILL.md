---
name: mac-migration
description: Mac migration assistant. Transfers configs, apps, and system settings from an old Mac to a new Mac. Covers data export, rsync transfer, automated installation, macOS settings restore, and Dock icon recovery. Use when migrating Macs, setting up a new Mac, or maintaining migration scripts.
---

# Mac Migration

An engineered workflow for fully migrating from an old Mac to a new Mac.

## Project Location

All migration files live in `~/.dotfiles/migrate/`:

```
migrate/
├── migrate.sh              # Run on old Mac: rsync data to new Mac
├── setup.sh                # Run on new Mac: orchestrates all steps
├── exclude.txt             # rsync exclusion list
├── data/                   # Exported data files
│   ├── Brewfile
│   ├── mas-apps.txt
│   ├── rsync-apps.txt
│   ├── dock-layout.json
│   ├── notification-prefs.plist
│   ├── finder/                 # Finder layout plist + sidebar SharedFileList files
│   ├── keyboard/               # currentHost keyboard modifier mappings
│   ├── gpg/                   # Exported public/secret keys + ownertrust (git-ignored)
│   ├── npm-global.txt
│   ├── pnpm-global.txt
│   └── vscode-extensions.txt
└── steps/
    ├── lib.sh              # Shared functions
    ├── 00-macos-settings.sh
    ├── 01-fix-permissions.sh
    ├── 02-xcode-cli.sh
    ├── 03-homebrew.sh
    ├── 04-brewfile.sh
    ├── 05-dotfiles-symlinks.sh
    ├── 06-node.sh
    ├── 07-pnpm.sh
    ├── 08-npm-global.sh
    ├── 09-editor-extensions.sh
    ├── 10-pkg-apps.sh
    ├── 11-install-apps.sh
    ├── 12-dock-restore.sh
    ├── 13-gpg-import.sh
    ├── 13-re-auth.sh
    ├── 14-clear-quarantine.sh
    ├── 15-notification-prefs.sh
    └── 16-finder-state.sh
```

## Quick Start

### Transfer data from old Mac

```bash
cd ~/.dotfiles/migrate
./migrate.sh user@newmac-ip
```

### Initialize new Mac

```bash
bash ~/migrate/setup.sh           # Run all steps
bash ~/migrate/setup.sh 00 03 09  # Run specific steps
bash ~/migrate/setup.sh 03-09     # Run a range
bash ~/migrate/setup.sh --list    # List all steps
```

## Step Execution Order

| Step | Name | Description |
|------|------|-------------|
| 00 | macOS Settings | Dock/Finder/Keyboard/Trackpad/Gatekeeper/Power/Volume/Control Center |
| 01 | Fix Permissions | SSH/GPG permission repair |
| 02 | Xcode CLI Tools | Install command line tools |
| 03 | Homebrew | Install Homebrew (incl. arm64 PATH) |
| 04 | Brewfile Restore | `brew bundle` install all packages and casks |
| 05 | Dotfile Symlinks | `rcup` restore symlinks |
| 06 | Node.js (n) | Install n + Node |
| 07 | pnpm/corepack | Enable corepack |
| 08 | Global npm/pnpm Packages | Reference list, manual install |
| 09 | Editor Extensions | VS Code extensions batch install |
| 10 | .pkg Apps | GPG Suite/Sogou Input/OpenVPN Connect auto-download & install |
| 11 | Install Apps | mas (App Store) + rsync apps |
| 12 | Restore Dock Icons | Restore icon order from `dock-layout.json` |
| 13 | GPG Import | Import exported public/secret keys and ownertrust |
| 14 | Clear Quarantine | Remove `com.apple.quarantine` from migrated/installed apps |
| 15 | Notification Prefs | Restore `com.apple.ncprefs.plist` after app installation |
| 16 | Finder State | Restore Finder sidebar SharedFileList files and layout plist |
| 17 | Re-authenticate | Checklist of services needing manual re-login |

## Maintenance Guide

Detailed docs split by topic:

- [Architecture & Flow](references/architecture.md) — Design, data flow, step dependencies
- [Data File Formats](references/data-files.md) — Format and update methods for each data file
- [macOS Settings Reference](references/macos-settings.md) — All system settings and current values
- [App Coverage Matrix](references/app-coverage.md) — Installation method for every app
- [Troubleshooting](references/troubleshooting.md) — Common issues and debugging

## Making Changes

- **Add an app**: Determine source (brew/mas/rsync/pkg), add to the corresponding data file
- **Add a system setting**: Edit `steps/00-macos-settings.sh`
- **Add a step**: Create file in `steps/`, update `STEPS` array in `setup.sh`
- **Exclude files**: Edit `exclude.txt`
- **Update data**: Keep `data/Brewfile` hand-edited; re-export editor/npm/pnpm lists as needed
