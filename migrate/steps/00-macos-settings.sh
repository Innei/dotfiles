#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "00" "macOS 系统设置"

SUDO_READY=0
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    SUDO_READY=1
elif sudo -n true 2>/dev/null; then
    SUDO_READY=1
else
    warn "sudo credential 不可用；需要 sudo 的设置会明确跳过"
    echo "  在 VM Terminal 中运行: sudo -v && bash ~/migrate/setup.sh 00"
fi

run_sudo_setting() {
    local description="$1"
    shift

    if [[ "$SUDO_READY" == "1" ]]; then
        sudo "$@" && ok "$description" || warn "$description 失败"
    else
        warn "跳过 $description (需要 sudo): sudo $*"
    fi
}

verify_default() {
    local label="$1"
    local expected="$2"
    shift 2

    local actual
    actual="$("$@" 2>/dev/null || true)"
    if [[ "$actual" == "$expected" ]]; then
        ok "$label = $actual"
    else
        warn "$label = ${actual:-<unset>} (期望: $expected)"
    fi
}

verify_preferred_search_provider() {
    local actual
    actual="$(defaults read -g NSPreferredWebServices 2>/dev/null \
        | awk -F'= ' '/NSProviderIdentifier/{gsub(/[;"]/, "", $2); print $2; exit}')"
    if [[ "$actual" == "com.google.www" ]]; then
        ok "默认搜索提供商 = $actual"
    else
        warn "默认搜索提供商 = ${actual:-<unset>} (期望: com.google.www)"
    fi
}

# ---- Dock (基础设置，图标在 step 12 恢复) ----
info "配置 Dock 基础设置 ..."
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock tilesize -int 37
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false
# 热角: 右下角 → 显示桌面 (4 = Desktop)
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0
ok "Dock 基础设置 (图标在 step 12 恢复)"

echo ""

# ---- Finder ----
info "配置 Finder ..."
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
ok "Finder"

# ---- Desktop / Window Manager ----
info "配置桌面 / Stage Manager 行为 ..."
defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 1
defaults write com.apple.WindowManager AutoHide -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager HideDesktop -bool false
defaults write com.apple.WindowManager StageManagerHideWidgets -bool false
defaults write com.apple.WindowManager StandardHideWidgets -bool false
ok "桌面点击、桌面图标、小组件、Stage Manager"

# ---- 键盘 ----
info "配置键盘 ..."
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2
ok "键盘 (快速重复，禁用按住弹出重音菜单)"

KEYBOARD_CURRENT_HOST_PLIST="$DATA_DIR/keyboard/current-host-global.plist"
if [[ -f "$KEYBOARD_CURRENT_HOST_PLIST" ]]; then
    info "恢复键盘修饰键映射 ..."
    /usr/bin/python3 - "$KEYBOARD_CURRENT_HOST_PLIST" "$HOME" <<'PY'
import glob
import os
import plistlib
import subprocess
import sys

source_path, home = sys.argv[1:3]
byhost = os.path.join(home, "Library", "Preferences", "ByHost")
targets = glob.glob(os.path.join(byhost, ".GlobalPreferences.*.plist"))
if targets:
    target_path = targets[0]
else:
    uuid = subprocess.check_output([
        "ioreg", "-rd1", "-c", "IOPlatformExpertDevice"
    ], text=True)
    platform_uuid = ""
    for line in uuid.splitlines():
        if "IOPlatformUUID" in line:
            platform_uuid = line.split('"')[-2]
            break
    if not platform_uuid:
        raise SystemExit("无法确定当前主机 UUID")
    os.makedirs(byhost, exist_ok=True)
    target_path = os.path.join(byhost, f".GlobalPreferences.{platform_uuid}.plist")

with open(source_path, "rb") as f:
    source = plistlib.load(f)

try:
    with open(target_path, "rb") as f:
        target = plistlib.load(f)
except FileNotFoundError:
    target = {}

copied = 0
for key, value in source.items():
    if key.startswith("com.apple.keyboard.modifiermapping."):
        target[key] = value
        copied += 1

with open(target_path, "wb") as f:
    plistlib.dump(target, f, fmt=plistlib.FMT_BINARY)

print(f"copied={copied} target={target_path}")
PY
    ok "键盘修饰键映射已恢复"
else
    warn "未找到键盘 currentHost 迁移数据: $KEYBOARD_CURRENT_HOST_PLIST"
fi

# ---- 菜单栏时钟 ----
info "配置菜单栏时钟 ..."
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
ok "菜单栏时钟"

# ---- 触控板 ----
info "配置触控板 ..."
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
ok "触控板"

# ---- 通用 ----
info "配置通用 ..."
defaults write -g AppleInterfaceStyle -string Dark
defaults write -g NSTableViewDefaultSizeMode -int 2
defaults write -g NSQuitAlwaysKeepsWindows -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g PMPrintingExpandedStateForPrint -bool true
defaults write -g AppleInterfaceStyleSwitchesAutomatically -int 1
defaults write -g AppleKeyboardUIMode -int 2
defaults write -g AppleShowAllExtensions -bool true
defaults write -g AppleMiniaturizeOnDoubleClick -bool false
defaults write -g AppleAntiAliasingThreshold -int 4
defaults write -g "com.apple.springing.enabled" -bool true
defaults write -g "com.apple.springing.delay" -float 0.5
defaults write -g "com.apple.swipescrolldirection" -bool false
defaults -currentHost write -g "com.apple.swipescrolldirection" -bool false
defaults write -g "com.apple.trackpad.forceClick" -bool true
defaults write -g "com.apple.keyboard.fnState" -bool true
defaults write -g "com.apple.sound.beep.flash" -bool false
ok "通用"

# ---- 语言 / 地区 / 默认 Web 搜索 ----
info "配置语言、地区和默认 Web 搜索 ..."
defaults write -g AppleLanguages -array "en-CN" "zh-Hans-CN"
defaults write -g AppleLocale -string "en_CN"
defaults write -g NSPreferredWebServices -dict \
    NSWebServicesProviderWebSearch '{NSDefaultDisplayName = Google; NSProviderIdentifier = "com.google.www";}'
ok "语言 / 地区 / Google 搜索"

# ---- Gatekeeper: 允许所有来源的 App ----
info "配置 Gatekeeper (允许任何来源) ..."
run_sudo_setting "Gatekeeper 已关闭 (允许任何来源)" spctl --master-disable
defaults write com.apple.LaunchServices LSQuarantine -bool false
ok "已关闭下载隔离提示"

# ---- 截图 ----
defaults write com.apple.screencapture disable-shadow -bool true
ok "截图去阴影"

# ---- 电源管理 ----
info "配置电源管理 (需要 sudo) ..."
run_sudo_setting "电源管理 (永不休眠)" pmset -a displaysleep 0 disksleep 0 sleep 0

# ---- 音量 ----
osascript -e "set volume output volume 24" 2>/dev/null && ok "音量设为 24" || true

# ---- Control Center 可见项 ----
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible Display" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible BentoBox" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible AudioVideoModule" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible FaceTime" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -int 0
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -int 0
ok "Control Center 菜单栏"

# ---- 文本替换 (NSUserDictionaryReplacementItems) ----
# 文本替换存在 NSGlobalDomain 里，已在 dotfiles 或手动迁移中覆盖
info "文本替换请确认已同步 (iCloud 或手动导入)"

echo ""
info "重启受影响的系统组件 ..."
killall "System Settings" Dock Finder SystemUIServer cfprefsd 2>/dev/null || true
ok "已重启 System Settings / Dock / Finder / SystemUIServer / cfprefsd"

echo ""
info "验证关键设置 ..."
verify_default "自然滚动(global)" "0" defaults read -g com.apple.swipescrolldirection
verify_default "自然滚动(currentHost)" "0" defaults -currentHost read -g com.apple.swipescrolldirection
verify_default "InitialKeyRepeat" "15" defaults read -g InitialKeyRepeat
verify_default "KeyRepeat" "2" defaults read -g KeyRepeat
verify_default "ApplePressAndHoldEnabled" "0" defaults read -g ApplePressAndHoldEnabled
verify_default "点击桌面显示桌面" "0" defaults read com.apple.WindowManager EnableStandardClickToShowDesktop
verify_default "默认 Finder 搜索范围" "SCcf" defaults read com.apple.finder FXDefaultSearchScope
verify_preferred_search_provider
verify_default "首选语言" "(
    \"en-CN\",
    \"zh-Hans-CN\"
)" defaults read -g AppleLanguages
verify_default "地区" "en_CN" defaults read -g AppleLocale
verify_default "三指轻点查询" "0" defaults read com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture
verify_default "蓝牙触控板三指轻点查询" "0" defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture

warn "语言/地区、键盘重复速度、滚动方向等会话级设置如果 UI 仍未刷新，需要重新登录或重启后完全生效"
