#!/bin/bash
set -euo pipefail

# ============================================
# 旧 Mac → 新 Mac 数据传输
# 用法: ./migrate.sh [--dry-run] [target]
#   target:  新电脑 hostname 或 IP (默认: newmac)
#   --dry-run / -n: 干跑模式，rsync 仅显示不传输
# ============================================

TARGET="${1:-newmac}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXCLUDE_FILE="$SCRIPT_DIR/exclude.txt"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail()  { echo -e "${RED}[FAIL]${NC} $*"; }
_dry()  { echo -e "\033[1;33m[DRY]\033[0m $*" >&2; }

# ---- 解析参数 ----
DRY_RUN=0
TARGET="newmac"
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=1 ;;
        *)            TARGET="$arg" ;;
    esac
done

if [[ "$DRY_RUN" == "1" ]]; then
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  ⚠  DRY-RUN 模式 — rsync 仅显示不传输${NC}"
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
fi

echo "========================================"
if [[ "$DRY_RUN" == "1" ]]; then
    echo "  Mac Migration (dry-run) → $TARGET"
else
    echo "  Mac Migration → $TARGET"
fi
echo "========================================"
echo ""

# --- 前置检查 ---
if [[ ! -f "$EXCLUDE_FILE" ]]; then
    fail "排除列表不存在: $EXCLUDE_FILE"
    exit 1
fi

info "测试 SSH 连接 ..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$TARGET" "echo ok" &>/dev/null; then
    fail "无法连接到 $TARGET"
    exit 1
fi
ok "SSH 连接正常"

REMOTE_HOME="$(ssh -o BatchMode=yes "$TARGET" 'printf "%s" "$HOME"' 2>/dev/null || true)"
if [[ -z "$REMOTE_HOME" || "$REMOTE_HOME" != /* ]]; then
    fail "无法获取目标机 HOME: $TARGET"
    exit 1
fi
ok "目标机 HOME: $REMOTE_HOME"
echo ""

# --- 导出数据 ---
if [[ "$DRY_RUN" == "1" ]]; then
    info "[dry-run] 跳过本地数据导出"
else
    info "导出数据 ..."
    info "Brewfile 使用手工维护版本: $SCRIPT_DIR/data/Brewfile"
    if [[ -f "$HOME/Library/Preferences/com.apple.ncprefs.plist" ]]; then
        cp "$HOME/Library/Preferences/com.apple.ncprefs.plist" \
            "$SCRIPT_DIR/data/notification-prefs.plist"
        ok "通知权限偏好已导出"
    else
        warn "通知权限偏好不存在，跳过导出"
    fi
    GPG_EXPORT_DIR="$SCRIPT_DIR/data/gpg"
    if command -v gpg &>/dev/null; then
        rm -rf "$GPG_EXPORT_DIR"
        mkdir -p "$GPG_EXPORT_DIR"
        chmod 700 "$GPG_EXPORT_DIR"

        if gpg --batch --list-keys &>/dev/null; then
            gpg --batch --armor --export > "$GPG_EXPORT_DIR/public.asc" \
                && ok "GPG public keys 已导出" \
                || warn "GPG public keys 导出失败"
        fi

        if gpg --batch --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec'; then
            if gpg --batch --armor --export-secret-keys > "$GPG_EXPORT_DIR/secret.asc"; then
                chmod 600 "$GPG_EXPORT_DIR/secret.asc"
                ok "GPG secret keys 已导出"
            else
                warn "GPG secret keys 导出失败；可能需要在源机解锁 key 后重试"
                rm -f "$GPG_EXPORT_DIR/secret.asc"
            fi
        else
            warn "未发现 GPG secret keys，跳过 secret key 导出"
        fi

        gpg --batch --export-ownertrust > "$GPG_EXPORT_DIR/ownertrust.txt" 2>/dev/null \
            && ok "GPG ownertrust 已导出" \
            || warn "GPG ownertrust 导出失败"
    else
        warn "gpg 命令不可用，跳过 GPG key 导出"
    fi
    code --list-extensions > "$SCRIPT_DIR/data/vscode-extensions.txt" 2>/dev/null || warn "VS Code 扩展列表失败"
    npm list -g --depth=0 2>/dev/null | tail -n +2 > "$SCRIPT_DIR/data/npm-global.txt" || true
    pnpm list -g --depth=0 2>/dev/null | tail -n +2 > "$SCRIPT_DIR/data/pnpm-global.txt" || true
    ok "数据导出完成"
fi
echo ""

# --- rsync ---
RSYNC_OPTS=(-av --exclude-from="$EXCLUDE_FILE")
if [[ "$DRY_RUN" == "1" ]]; then
    RSYNC_OPTS+=(--dry-run)
fi

remote_dest() {
    local path="$1"
    printf "%s:%q" "$TARGET" "$path"
}

remote_home_path() {
    local relative="$1"
    relative="${relative#/}"
    printf "%s/%s" "$REMOTE_HOME" "$relative"
}

sync_item() {
    local src="$1"
    local dest_path="$2"
    if [[ -e "$src" ]]; then
        if [[ -d "$src" && ! -L "$src" ]]; then
            rsync "${RSYNC_OPTS[@]}" "$src/" "$(remote_dest "$dest_path/")"
        else
            rsync "${RSYNC_OPTS[@]}" "$src" "$(remote_dest "$dest_path")"
        fi
    fi
}

# === Home 目录 ===
info "同步 Home 目录 ..."
for item in \
    .claude .claude.json .codex .dotfiles .hammerspoon .pi \
    .ssh .npmrc .wakatime.cfg \
    .zshrc .zprofile .zsh_history; do
    sync_item "$HOME/$item" "$(remote_home_path "$item")"
done

# === ~/.config ===
info "同步 ~/.config ..."
if [[ "$DRY_RUN" == "1" ]]; then
    _dry "ssh $TARGET mkdir -p '$REMOTE_HOME/.config'"
else
    ssh "$TARGET" "mkdir -p \"\$HOME/.config\"" 2>/dev/null
fi
for item in ghostty zsh starship.toml vscode-nvim gh op raycast joshuto vim; do
    sync_item "$HOME/.config/$item" "$(remote_home_path ".config/$item")"
done

# === zinit ===
if [[ -d "$HOME/.local/share/zinit" ]]; then
    info "同步 zinit ..."
    rsync "${RSYNC_OPTS[@]}" "$HOME/.local/share/zinit/" "$(remote_dest "$(remote_home_path ".local/share/zinit/")")"
fi

# === 字体 ===
info "同步字体 ..."
rsync "${RSYNC_OPTS[@]}" "$HOME/Library/Fonts/" "$(remote_dest "$(remote_home_path "Library/Fonts/")")"
rsync "${RSYNC_OPTS[@]}" "$HOME/Library/FontCollections/" "$(remote_dest "$(remote_home_path "Library/FontCollections/")")" 2>/dev/null || true

# === App 数据 ===
info "同步 App 数据 ..."
sync_item "$HOME/Library/Application Support/Code/User/" \
    "$(remote_home_path "Library/Application Support/Code/User/")"
sync_item "$HOME/Library/Application Support/lazygit/" \
    "$(remote_home_path "Library/Application Support/lazygit/")"
sync_item "$HOME/Library/Application Support/Surge/" \
    "$(remote_home_path "Library/Application Support/Surge/")"
sync_item "$HOME/Library/Preferences/com.googlecode.iterm2.plist" \
    "$(remote_home_path "Library/Preferences/")"

# === /Applications (rsync brew/mas 装不了的) ===
RSYNC_APPS_FILE="$SCRIPT_DIR/data/rsync-apps.txt"
if [[ -f "$RSYNC_APPS_FILE" ]]; then
    info "同步 /Applications (rsync 列表中的 App) ..."
    if [[ "$DRY_RUN" == "1" ]]; then
        _dry "ssh $TARGET mkdir -p '$REMOTE_HOME/migrate/apps'"
    else
        ssh "$TARGET" "mkdir -p \"\$HOME/migrate/apps\"" 2>/dev/null
    fi
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        app_path="/Applications/$line.app"
        if [[ -d "$app_path" ]]; then
            info "  rsync $line.app ..."
            rsync "${RSYNC_OPTS[@]}" --delete "$app_path/" "$(remote_dest "$(remote_home_path "migrate/apps/$line.app/")")"
        else
            warn "  $line.app 不存在，跳过"
        fi
    done < "$RSYNC_APPS_FILE"
fi

# === 迁移脚本本身 ===
info "传输迁移脚本 ..."
rsync "${RSYNC_OPTS[@]}" "$SCRIPT_DIR/" "$(remote_dest "$(remote_home_path "migrate/")")"

echo ""
if [[ "$DRY_RUN" == "1" ]]; then
    echo "========================================"
    ok "Dry-run 数据传输完成 — 未传输任何文件"
    echo ""
    echo "去掉 --dry-run 以执行实际传输:"
    echo "  $0 $TARGET"
    echo "========================================"
else
    # === 验证 ===
    info "验证 ..."
    FAILED=0
    for item in .ssh .dotfiles .zshrc .config/zsh .config/ghostty migrate/data/gpg; do
        if ssh "$TARGET" "test -e \$HOME/$item" 2>/dev/null; then
            ok "✓ $item"
        else
            warn "✗ $item"
            FAILED=$((FAILED + 1))
        fi
    done

    echo ""
    echo "========================================"
    ok "数据传输完成！"
    echo ""
    echo "在新电脑上执行:"
    echo "  bash ~/migrate/setup.sh           # 全部执行"
    echo "  bash ~/migrate/setup.sh 03 09     # 只执行 step 03 和 09"
    echo "  bash ~/migrate/setup.sh --list     # 查看所有步骤"
    echo "========================================"
fi
