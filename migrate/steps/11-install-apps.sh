#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "11" "App 安装"

require_brew

UNWANTED_APPLE_APPS=(
    "GarageBand"
    "iMovie"
)

PROTECTED_SYSTEM_APPLE_APPS=(
    "Music"
)

UNWANTED_APPLE_SUPPORT_PATHS=(
    "/Library/Application Support/GarageBand"
    "/Library/Application Support/Logic"
    "/Library/Audio/Apple Loops"
    "/Library/Application Support/iMovie"
    "$HOME/Library/Application Support/iMovie"
    "$HOME/Music/GarageBand"
)

clear_app_quarantine() {
    local app_path="$1"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        _dry "xattr -r -d com.apple.quarantine $app_path"
        return 0
    fi

    if xattr -lr "$app_path" 2>/dev/null | grep -q 'com.apple.quarantine'; then
        if xattr -r -d com.apple.quarantine "$app_path" 2>/dev/null; then
            return 0
        elif sudo -n true 2>/dev/null; then
            sudo xattr -r -d com.apple.quarantine "$app_path"
        else
            warn "需要 sudo 清理 quarantine: sudo xattr -r -d com.apple.quarantine '$app_path'"
            return 0
        fi
    fi
}

remove_unwanted_apple_apps() {
    local app_name=""
    local app_path=""
    local support_path=""

    info "清理不需要的 Apple 预装应用 ..."

    for app_name in "${UNWANTED_APPLE_APPS[@]}"; do
        app_path="/Applications/$app_name.app"
        if [[ ! -d "$app_path" ]]; then
            ok "  ✓ $app_name (未安装)"
            continue
        fi

        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            _dry "sudo rm -rf $app_path"
            continue
        fi

        info "  删除 $app_name ..."
        if sudo rm -rf "$app_path"; then
            ok "  ✓ $app_name 已删除"
        else
            warn "  ✗ $app_name 删除失败: $app_path"
        fi
    done

    for app_name in "${PROTECTED_SYSTEM_APPLE_APPS[@]}"; do
        app_path="/System/Applications/$app_name.app"
        if [[ -d "$app_path" ]]; then
            warn "  $app_name 是系统应用 ($app_path)，保留系统卷内置版本"
        fi
    done

    for support_path in "${UNWANTED_APPLE_SUPPORT_PATHS[@]}"; do
        if [[ ! -e "$support_path" ]]; then
            continue
        fi

        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            _dry "sudo rm -rf $support_path"
            continue
        fi

        info "  删除素材/支持目录 $support_path ..."
        if sudo rm -rf "$support_path"; then
            ok "  ✓ 已删除 $support_path"
        else
            warn "  ✗ 删除失败: $support_path"
        fi
    done
}

remove_unwanted_apple_apps

# ---- mas (App Store) ----
MAS_FILE="$DATA_DIR/mas-apps.txt"
if [[ -f "$MAS_FILE" ]]; then
    if ! has mas; then
        info "安装 mas ..."
        brew install mas
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        info "dry-run: 将检查 mas 登录状态后安装 $MAS_FILE 中的 App Store 应用"
    elif ! has mas; then
        warn "mas 不可用，跳过 App Store 应用安装"
    else
        export MAS_NO_AUTO_INDEX=1
        sudo -v 2>/dev/null || true
        info "安装 App Store 应用 ..."
        while IFS= read -r line; do
            # 跳过注释和空行
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue

            id=$(echo "$line" | awk '{print $1}')
            name=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//')

            if [[ -d "/Applications/$name.app" ]]; then
                ok "  ✓ $name (已安装)"
            else
                info "  安装 $name ($id) ..."
                if mas install "$id" || mas get "$id"; then
                    ok "  ✓ $name"
                else
                    warn "  ✗ $name 安装失败"
                fi
            fi
        done < "$MAS_FILE"
    fi
else
    warn "未找到 $MAS_FILE"
fi

echo ""

# ---- rsync Apps (从旧电脑传过来的) ----
RSYNC_FILE="$DATA_DIR/rsync-apps.txt"
RSYNC_DIR="$HOME/migrate/apps"

if [[ -d "$RSYNC_DIR" ]]; then
    info "从 $RSYNC_DIR 复制 App 到 /Applications ..."
    for app_dir in "$RSYNC_DIR"/*.app; do
        [[ ! -d "$app_dir" ]] && continue
        app_name=$(basename "$app_dir")
        if [[ -d "/Applications/$app_name" ]]; then
            ok "  ✓ $app_name (已存在)"
            clear_app_quarantine "/Applications/$app_name" || warn "  ✗ $app_name quarantine 清理失败"
        else
            info "  复制 $app_name ..."
            cp -R "$app_dir" "/Applications/$app_name" && {
                clear_app_quarantine "/Applications/$app_name" || warn "  ✗ $app_name quarantine 清理失败"
                ok "  ✓ $app_name"
            } || warn "  ✗ $app_name 复制失败"
        fi
    done
elif [[ -f "$RSYNC_FILE" ]]; then
    warn "Apps 目录不存在: $RSYNC_DIR"
    info "请先在旧电脑执行 migrate.sh 同步 Apps"
fi
