# macOS Settings Reference

All settings applied in `steps/00-macos-settings.sh`.

## Dock

| Setting | Value | Key |
|---------|-------|-----|
| Position | left | `com.apple.dock orientation` |
| Tile size | 37 | `com.apple.dock tilesize` |
| Minimize to app | true | `com.apple.dock minimize-to-application` |
| Show recents | false | `com.apple.dock show-recents` |
| Auto-switch spaces | false | `com.apple.dock mru-spaces` |
| Hot corner BR | Desktop (4) | `com.apple.dock wvous-br-corner` |
| Hot corner BR modifier | none (0) | `com.apple.dock wvous-br-modifier` |

Hot corner values: 1=none, 2=Mission Control, 3=App Windows, 4=Desktop, 5=Screensaver, 10=Sleep, 11=Lock Screen, 12=Launchpad

## Finder

| Setting | Value | Key |
|---------|-------|-----|
| Show path bar | true | `com.apple.finder ShowPathbar` |
| Show status bar | false | `com.apple.finder ShowStatusBar` |
| Default view | list (Nlsv) | `com.apple.finder FXPreferredViewStyle` |
| New window target | Home (PfHm) | `com.apple.finder NewWindowTarget` |
| Show external drives | true | `com.apple.finder ShowExternalHardDrivesOnDesktop` |
| Show internal drives | false | `com.apple.finder ShowHardDrivesOnDesktop` |
| Search current folder | true | `com.apple.finder FXDefaultSearchScope = SCcf` |

## Desktop / Window Manager

| Setting | Value | Key |
|---------|-------|-----|
| Click wallpaper to show desktop | false | `com.apple.WindowManager EnableStandardClickToShowDesktop` |
| App window grouping | 1 | `com.apple.WindowManager AppWindowGroupingBehavior` |
| Stage Manager auto hide | false | `com.apple.WindowManager AutoHide` |
| Hide desktop items | false | `com.apple.WindowManager HideDesktop` |
| Hide widgets in Stage Manager | false | `com.apple.WindowManager StageManagerHideWidgets` |
| Hide widgets on desktop | false | `com.apple.WindowManager StandardHideWidgets` |

## Keyboard

| Setting | Value | Key |
|---------|-------|-----|
| Initial repeat delay | 15 | `-g InitialKeyRepeat` |
| Repeat rate | 2 (fast) | `-g KeyRepeat` |
| Press-and-hold accents | false | `-g ApplePressAndHoldEnabled` |
| Tab keyboard navigation | mode 2 | `-g AppleKeyboardUIMode` |
| Fn key switches input | true | `-g com.apple.keyboard.fnState` |

## Trackpad

| Setting | Value | Key |
|---------|-------|-----|
| Tap to click | false | `com.apple.AppleMultitouchTrackpad Clicking` |
| Right click | true | `...TrackpadRightClick` |
| Three finger drag | false | `...TrackpadThreeFingerDrag` |
| Three finger tap lookup | false | `...TrackpadThreeFingerTapGesture` |
| Click threshold 1 | 1 | `...FirstClickThreshold` |
| Click threshold 2 | 1 | `...SecondClickThreshold` |
| Force click | true | `-g com.apple.trackpad.forceClick` |

Values are written to both `com.apple.AppleMultitouchTrackpad` and `com.apple.driver.AppleBluetoothMultitouch.trackpad` where applicable.

## Global (NSGlobalDomain)

| Setting | Value | Key |
|---------|-------|-----|
| Interface style | Dark | `-g AppleInterfaceStyle` |
| Auto dark mode switch | true | `-g AppleInterfaceStyleSwitchesAutomatically` |
| Show all extensions | true | `-g AppleShowAllExtensions` |
| Double-click minimize | false | `-g AppleMiniaturizeOnDoubleClick` |
| Anti-aliasing threshold | 4 | `-g AppleAntiAliasingThreshold` |
| Scroll direction | non-natural (false) | `-g com.apple.swipescrolldirection` |
| Spring loading | true/0.5s | `-g com.apple.springing.*` |
| Beep flash | false | `-g com.apple.sound.beep.flash` |
| Sidebar icon size | medium (2) | `-g NSTableViewDefaultSizeMode` |
| Keep windows on quit | true | `-g NSQuitAlwaysKeepsWindows` |
| Expand save dialog | true | `-g NSNavPanelExpandedStateForSaveMode` |
| Expand print dialog | true | `-g PMPrintingExpandedStateForPrint` |

## Language / Region / Search

| Setting | Value | Key |
|---------|-------|-----|
| Languages | en-CN, zh-Hans-CN | `-g AppleLanguages` |
| Locale | en_CN | `-g AppleLocale` |
| Web search provider | Google | `-g NSPreferredWebServices` |

## Security

| Setting | Value | Command |
|---------|-------|---------|
| Gatekeeper | allow anywhere | `sudo spctl --master-disable` |
| Download quarantine | disabled | `com.apple.LaunchServices LSQuarantine false` |

## Screen & Power

| Setting | Value | Command |
|---------|-------|---------|
| Screenshot shadow | disabled | `com.apple.screencapture disable-shadow true` |
| Display sleep | 2 min | `sudo pmset -a displaysleep 2` |
| Disk sleep | 10 min | `sudo pmset -a disksleep 10` |
| System sleep | 1 min | `sudo pmset -a sleep 1` |

## Menu Bar

| Setting | Value | Key |
|---------|-------|-----|
| Clock: AM/PM | show | `com.apple.menuextra.clock ShowAMPM` |
| Clock: date | hide | `...ShowDate 0` |
| Clock: day of week | show | `...ShowDayOfWeek` |
| Output volume | 24% | `osascript -e "set volume output volume 24"` |

## Control Center

Visible: Battery, Clock, Display, BentoBox
Visible: WiFi
Hidden: AudioVideoModule, FaceTime, FocusModes, Sound

Written to `com.apple.controlcenter "NSStatusItem Visible <Item>"`.

## Text Replacements (not automated)

Stored in `-g NSUserDictionaryReplacementItems`. Syncs via iCloud with Apple ID login. Contains custom shortcuts like `uu`→email, `msd`→马上到.

## Notifications

Notification permission choices are restored separately by step 15 from `data/notification-prefs.plist`.

This file is exported from `~/Library/Preferences/com.apple.ncprefs.plist` on the source Mac. Restoring it prevents repeated allow/deny prompts for apps that already have a recorded bundle ID on the source machine, such as Chrome, VS Code, Ghostty, Telegram, and other installed apps.

During restore, `/Applications/*.app` rows are filtered to apps that exist on the target Mac. This avoids carrying notification settings for apps intentionally omitted from the migration.

macOS does not expose a safe global command-line switch to silently approve or deny every unknown future app. Apps absent from the source notification preferences can still prompt on first launch.

## Not Automatically Migrated

The script intentionally avoids raw `defaults export/import` for every domain. Many keys are runtime state rather than settings, such as window frames, heartbeat timestamps, recent files, App Store/iCloud account state, device-specific bookmarks, Dock persistent item binary bookmarks, and migration-version markers.

Dock icon order is handled separately by step 12 from `data/dock-layout.json`. Text replacements are left to iCloud/manual review because they may contain personal email addresses and account-specific data.
