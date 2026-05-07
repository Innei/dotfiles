#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "10" "安装 .pkg 应用"

# Dry-run: 汇总报告，跳过下载/安装
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    DL_DIR="$HOME/Downloads/_migrate_pkgs"
    info "以下 .pkg 应用将被下载并安装 (到 $DL_DIR):"
    echo ""
    if [[ -d "/Applications/GPG Keychain.app" ]]; then
        ok "GPG Suite — 已安装 ✓"
    else
        info "GPG Suite — 将下载 DMG 并安装 (.pkg)"
    fi
    if [[ -d "/Library/Input Methods/SogouInput.app" ]] || [[ -d "$HOME/Library/Input Methods/SogouInput.app" ]]; then
        ok "搜狗输入法 — 已安装 ✓"
    else
        info "搜狗输入法 — 将下载 ZIP 并安装输入法 bundle"
    fi
    if [[ -d "/Applications/OpenVPN Connect.app" ]]; then
        ok "OpenVPN Connect — 已安装 ✓"
    else
        info "OpenVPN Connect — 将下载 DMG 并安装对应架构 .pkg"
    fi
    exit 0
fi

DL_DIR="$HOME/Downloads/_migrate_pkgs"
mkdir -p "$DL_DIR"

# ---- GPG Suite ----
if [[ -d "/Applications/GPG Keychain.app" ]]; then
    ok "GPG Suite 已安装"
else
    info "下载 GPG Suite ..."
    GPG_URL="https://releases.gpgtools.org/nightlies/GPG_Suite-3618n.dmg"
    curl -fSL -o "$DL_DIR/GPG_Suite.dmg" "$GPG_URL"
    ok "下载完成: $DL_DIR/GPG_Suite.dmg"
    if ! echo "6e1c9280cf825ea1a27498c539b8126be916327d797ea71066ca54638c1eddf5  $DL_DIR/GPG_Suite.dmg" | shasum -a 256 -c -; then
        fail "GPG Suite checksum 校验失败"
        exit 1
    fi

    info "挂载并安装 GPG Suite ..."
    hdiutil attach "$DL_DIR/GPG_Suite.dmg" -quiet
    # GPG Suite installer 是 .pkg inside DMG
    PKG=$(ls /Volumes/GPG*/*.pkg /Volumes/GPG*/*/Install*.pkg 2>/dev/null | head -1)
    if [[ -n "$PKG" ]]; then
        sudo installer -pkg "$PKG" -target /
        ok "GPG Suite 安装完成"
    else
        warn "未找到 .pkg，请手动安装: 打开 $DL_DIR/GPG_Suite.dmg"
    fi
    hdiutil detach /Volumes/GPG* -quiet 2>/dev/null || true
fi

echo ""

# ---- 搜狗输入法 ----
if [[ -d "/Library/Input Methods/SogouInput.app" ]] || [[ -d "$HOME/Library/Input Methods/SogouInput.app" ]]; then
    ok "搜狗输入法已安装"
else
    info "下载搜狗输入法 ..."
    SOGOU_URL="http://ime.gtimg.com/pc/sogou_mac_new_guanwang_620a.zip"
    curl -fSL -o "$DL_DIR/sogou_mac.zip" "$SOGOU_URL"
    ok "下载完成: $DL_DIR/sogou_mac.zip"

    info "解压并安装搜狗输入法 ..."
    SOGOU_WORK="$DL_DIR/sogou_mac"
    rm -rf "$SOGOU_WORK"
    unzip -o -q "$DL_DIR/sogou_mac.zip" -d "$SOGOU_WORK"
    INNER_ZIP="$SOGOU_WORK/sogou_mac_new_guanwang_620a.app/Contents/Resources/SogouInput.zip"
    if [[ -f "$INNER_ZIP" ]]; then
        rm -rf "$SOGOU_WORK/input"
        unzip -o -q "$INNER_ZIP" -d "$SOGOU_WORK/input"
        sudo mkdir -p "/Library/Input Methods"
        sudo rm -rf "/Library/Input Methods/SogouInput.app"
        sudo ditto "$SOGOU_WORK/input/SogouInput.app" "/Library/Input Methods/SogouInput.app"
        sudo chown -R root:wheel "/Library/Input Methods/SogouInput.app"
        ok "搜狗输入法安装完成"
    else
        warn "未找到 SogouInput.zip，请手动打开: $SOGOU_WORK/sogou_mac_new_guanwang_620a.app"
    fi
fi

echo ""

# ---- OpenVPN Connect ----
if [[ -d "/Applications/OpenVPN Connect.app" ]]; then
    ok "OpenVPN Connect 已安装"
else
    info "下载 OpenVPN Connect ..."
    OPENVPN_URL="https://openvpn.net/downloads/openvpn-connect-v3-macos.dmg"
    curl -fSL -o "$DL_DIR/OpenVPN_Connect.dmg" "$OPENVPN_URL"
    ok "下载完成: $DL_DIR/OpenVPN_Connect.dmg"

    info "挂载并安装 OpenVPN Connect ..."
    hdiutil attach "$DL_DIR/OpenVPN_Connect.dmg" -quiet
    if [[ "$(uname -m)" == "arm64" ]]; then
        PKG=$(find /Volumes -maxdepth 3 -name "*arm64*Installer_signed.pkg" | head -1)
    else
        PKG=$(find /Volumes -maxdepth 3 -name "*x86_64*Installer_signed.pkg" | head -1)
    fi
    if [[ -z "${PKG:-}" ]]; then
        PKG=$(find /Volumes -maxdepth 3 -name "OpenVPN*.pkg" | head -1)
    fi
    if [[ -n "$PKG" ]]; then
        sudo installer -pkg "$PKG" -target /
        ok "OpenVPN Connect 安装完成"
    else
        warn "未找到 OpenVPN .pkg，请手动安装: 打开 $DL_DIR/OpenVPN_Connect.dmg"
    fi
    hdiutil detach "/Volumes/OpenVPN Connect" -quiet 2>/dev/null || hdiutil detach /Volumes/OpenVPN* -quiet 2>/dev/null || true
fi

echo ""
info "安装包保留在: $DL_DIR (可手动删除)"
