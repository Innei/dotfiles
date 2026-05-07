# Troubleshooting

## migrate.sh Issues

### SSH connection failed

```
Error: 无法连接到 newmac
```

- Verify IP/hostname: `ssh user@ip echo ok`
- Ensure key-based auth is set up: copy `~/.ssh/id_ed25519.pub` to new Mac's `~/.ssh/authorized_keys`
- Check firewall on new Mac: System Settings → Network → Firewall

### rsync partial failures

Some items may fail if target directories don't exist:

```bash
# Fix on new Mac
mkdir -p ~/.config ~/Library/"Application Support"/Code/User
```

### Brewfile export fails

```
warn "Homebrew Brewfile 导出失败"
```

Homebrew might not be installed. Use the pre-built `data/Brewfile` instead.

## setup.sh Issues

### bash 3.2 "declare -A" error

setup.sh is already compatible with bash 3.2 (uses `|`-delimited arrays). If you see this error, an older version is being used.

### Step 03: Homebrew install hangs

ARM Macs need Rosetta for some bottles:

```bash
sudo softwareupdate --install-rosetta
```

### Step 04: Brewfile fails on specific cask

Comment out the failing line in `data/Brewfile`, re-run:

```bash
# Edit file
nano ~/migrate/data/Brewfile
# Re-run just this step
bash ~/migrate/setup.sh 04
```

### Step 10: .pkg download fails

Downloads are cached in `~/Downloads/_migrate_pkgs/`. If a download fails:

1. Check URL is still valid (may need updating)
2. Download manually from the URL
3. Install manually: double-click the .dmg/.pkg

### Step 12: Dock icons not restored

**Symptom:** Dock is empty or has wrong icons after step 12.

**Diagnosis:**
```bash
# Check if dock-layout.json exists
cat ~/migrate/data/dock-layout.json

# Check current Dock
defaults read com.apple.dock persistent-apps | grep file-label
```

**Fix:**
- Ensure all apps are installed first (steps 10-11)
- Re-run: `bash ~/migrate/setup.sh 12`
- If python plist write fails, manually drag icons

### Step 00: Gatekeeper "sudo spctl --master-disable" fails

Need admin password. If running unattended, pre-authorize:

```bash
sudo spctl --master-disable
```

Or skip and do it manually: System Settings → Privacy & Security → Allow apps from: Anywhere.

## Data File Issues

### Dock layout outdated

Re-export on old Mac:

```bash
/usr/bin/python3 -c "
import plistlib, json
with open('$HOME/Library/Preferences/com.apple.dock.plist', 'rb') as f:
    dock = plistlib.load(f)
apps = [{'label': i['tile-data']['file-label'],
         'path': i['tile-data']['file-data']['_CFURLString'].replace('file://','')}
        for i in dock.get('persistent-apps', [])]
others = [{'label': i['tile-data']['file-label'],
           'path': i['tile-data']['file-data']['_CFURLString'].replace('file://','')}
          for i in dock.get('persistent-others', [])]
print(json.dumps({'apps': apps, 'others': others}, indent=2, ensure_ascii=False))
" > ~/.dotfiles/migrate/data/dock-layout.json
```

### GPG Suite download URL outdated

Check latest URL:
```bash
curl -sL https://gpgtools.org/gpgsuite | grep -oE 'https://releases\.gpgtools\.com/[^"]+\.dmg' | head -1
```

Update the URL in `steps/10-pkg-apps.sh`.

### mas not signed in

mas requires App Store sign-in:
```bash
# Sign in first
mas signin "apple_id@example.com"
```

## Testing Individual Steps

Run any step in isolation:

```bash
# Test on current machine (may skip if already installed)
bash ~/.dotfiles/migrate/steps/00-macos-settings.sh
bash ~/.dotfiles/migrate/steps/12-dock-restore.sh
```

Dry-run rsync to preview what would transfer:

```bash
rsync -avn --exclude-from=~/.dotfiles/migrate/exclude.txt ~/.dotfiles/ newmac:~/.dotfiles/
```
