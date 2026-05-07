# App Coverage Matrix

Every app in `/Applications` mapped to its installation method.

## Brew Cask (Brewfile)

| App | Cask Name |
|-----|-----------|
| 1Password | `1password` |
| 1Password CLI | `1password-cli` |
| CleanMyMac X | `cleanmymac` |
| Clash Verge | `clash-verge-rev` |
| Codex CLI | `codex` |
| Ghostty | `ghostty` |
| Google Chrome | `google-chrome` |
| Hammerspoon | `hammerspoon` |
| Icon Composer | `icon-composer` |
| iTerm | `iterm2` |
| OrbStack | `orbstack` |
| Proxyman | `proxyman` |
| Raycast | `raycast` |
| Surge | `surge` |
| Visual Studio Code | `visual-studio-code` |
| Agave Nerd Font | `font-agave-nerd-font` |
| ComicShannsMono Nerd Font | `font-comic-shanns-mono-nerd-font` |

## App Store (mas)

| App | mas ID |
|-----|--------|
| Bob | 1630034110 |
| Medis | 1579200037 |
| Navicat Premium | 1594061654 |
| Xcode | 497799835 |

## rsync /Applications

| App | Note |
|-----|------|
| Apparency | |
| CC Switch | |
| Capture One | |
| CleanShot X | |
| Discord | |
| Fork | |
| IINA | |
| Lark | |
| MetaImage | |
| NeteaseMusic | |
| OpenInTerminal | |
| Pixelmator Pro | |
| PixelSnap 2 | |
| ProcessReporter | dev.innei |
| Supercharge | |
| TablePlus | |
| Telegram | |
| Typeless | |
| Typora | |
| WeChat | |

## .pkg Auto-Install (step 10)

| App | Download URL | Method |
|-----|-------------|--------|
| GPG Suite (Keychain) | `https://releases.gpgtools.org/nightlies/GPG_Suite-3618n.dmg` | curl → checksum → hdiutil → `sudo installer -pkg` |
| Sogou Input | `http://ime.gtimg.com/pc/sogou_mac_new_guanwang_620a.zip` | curl → unzip nested `SogouInput.zip` → ditto to `/Library/Input Methods` |
| OpenVPN Connect | `https://openvpn.net/downloads/openvpn-connect-v3-macos.dmg` | curl → hdiutil → install architecture-specific `.pkg` |

## Not Migrating

| App | Reason |
|-----|--------|
| Cherry Studio | Not needed |
| ClashMac | Replaced by Clash Verge Rev |
| Cursor | Not used anymore |
| Folo | Removed |
| LarkSuite | Duplicate of Lark |
| Pixelmator Pro 2 | Same bundle ID as Pixelmator Pro |
| Quantumult X | Removed |
| Shadowrocket | Removed |
| TestFlight | Removed |

## System Apps (pre-installed)

Safari, Photos, System Settings, iPhone Mirroring — no action needed.
