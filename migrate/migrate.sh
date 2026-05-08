#!/bin/bash
set -euo pipefail

# ============================================
# 旧 Mac → 新 Mac 数据传输
# 用法: ./migrate.sh [--dry-run] [target]
#   target:  新电脑 hostname 或 IP (默认: newmac)
#   --dry-run / -n: 干跑模式，rsync 仅显示不传输
# 环境变量:
#   MIGRATE_SOURCE_SUDO_PASSWORD  本机 sudo 密码，未设置时交互读取
#   MIGRATE_REMOTE_SUDO_PASSWORD  目标机 sudo 密码，未设置时交互读取
#   MIGRATE_SUDO_PASSWORD         两边密码相同时可用作默认值
#   MIGRATE_SKIP_POWER_PREFLIGHT=1 跳过 sudo 校验、pmset 和 caffeinate
#   MIGRATE_SKIP_RSYNC_PREFLIGHT=1 跳过 rsync 版本检查和自动升级
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

SOURCE_SUDO_PASSWORD="${MIGRATE_SOURCE_SUDO_PASSWORD:-${SOURCE_SUDO_PASSWORD:-${MIGRATE_SUDO_PASSWORD:-}}}"
REMOTE_SUDO_PASSWORD="${MIGRATE_REMOTE_SUDO_PASSWORD:-${REMOTE_SUDO_PASSWORD:-${MIGRATE_SUDO_PASSWORD:-}}}"
LOCAL_CAFFEINATE_PID=""
RSYNC_BIN="rsync"
REMOTE_RSYNC_BIN="rsync"
RSYNC_BIN_MAJOR=0
REMOTE_RSYNC_BIN_MAJOR=0

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

prompt_secret() {
    local prompt="$1"
    local var_name="$2"
    local value=""

    if [[ ! -t 0 ]]; then
        fail "当前不是交互式 TTY，无法读取 $prompt"
        echo "  可通过环境变量传入: $var_name=..."
        exit 1
    fi

    printf "%s" "$prompt"
    IFS= read -r -s value
    printf "\n"
    printf -v "$var_name" "%s" "$value"
}

local_sudo() {
    printf '%s\n' "$SOURCE_SUDO_PASSWORD" | sudo -S -p '' "$@"
}

remote_sudo_validate() {
    printf '%s\n' "$REMOTE_SUDO_PASSWORD" | ssh "$TARGET" '
        IFS= read -r pw
        printf "%s\n" "$pw" | sudo -S -p "" -v
    '
}

remote_sudo_pmset_never_sleep() {
    printf '%s\n' "$REMOTE_SUDO_PASSWORD" | ssh "$TARGET" '
        IFS= read -r pw
        printf "%s\n" "$pw" | sudo -S -p "" pmset -a sleep 0 disksleep 0 displaysleep 0
    '
}

sync_raycast_keychain() {
    local accounts=(database_key urlcache_key)
    local account=""
    local secret=""
    local encoded=""
    local payload=""

    if [[ "$DRY_RUN" == "1" ]]; then
        _dry "同步 Raycast Keychain items: ${accounts[*]}"
        return 0
    fi
    if [[ -z "$REMOTE_SUDO_PASSWORD" ]]; then
        warn "目标机密码为空，跳过 Raycast Keychain 解锁/迁移"
        return 0
    fi
    if ! command -v security >/dev/null 2>&1; then
        warn "security 命令不可用，跳过 Raycast Keychain 迁移"
        return 0
    fi

    for account in "${accounts[@]}"; do
        if secret="$(security find-generic-password -s Raycast -a "$account" -w 2>/dev/null)"; then
            encoded="$(printf '%s' "$secret" | /usr/bin/base64 | tr -d '\n')"
            payload+="${account}"$'\t'"${encoded}"$'\n'
        else
            warn "无法读取本机 Raycast Keychain item: $account"
        fi
    done

    if [[ -z "$payload" ]]; then
        warn "没有可同步的 Raycast Keychain item"
        return 0
    fi

    info "同步 Raycast Keychain items ..."
    {
        printf '%s\n' "$REMOTE_SUDO_PASSWORD"
        printf '%s' "$payload"
    } | ssh "$TARGET" '
        IFS= read -r keychain_pw
        security unlock-keychain -p "$keychain_pw" "$HOME/Library/Keychains/login.keychain-db" >/dev/null 2>&1 || true
        while IFS=$'\''\t'\'' read -r account encoded; do
            [[ -n "$account" && -n "$encoded" ]] || continue
            secret="$(printf "%s" "$encoded" | /usr/bin/base64 -D)"
            security delete-generic-password -s Raycast -a "$account" >/dev/null 2>&1 || true
            security add-generic-password -s Raycast -a "$account" -l Raycast -A -w "$secret" "$HOME/Library/Keychains/login.keychain-db" >/dev/null
        done
    ' && ok "Raycast Keychain items 已同步"
}

start_power_preflight() {
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[dry-run] 跳过本机/目标机 sudo 与休眠策略前置设置"
        return 0
    fi
    if [[ "${MIGRATE_SKIP_POWER_PREFLIGHT:-0}" == "1" ]]; then
        warn "MIGRATE_SKIP_POWER_PREFLIGHT=1，跳过 sudo 校验、pmset 和 caffeinate"
        return 0
    fi

    if [[ -z "$SOURCE_SUDO_PASSWORD" ]]; then
        prompt_secret "请输入当前机器 sudo 密码: " SOURCE_SUDO_PASSWORD
    fi
    if [[ -z "$REMOTE_SUDO_PASSWORD" ]]; then
        prompt_secret "请输入目标机器 sudo 密码: " REMOTE_SUDO_PASSWORD
    fi

    info "校验本机 sudo 密码 ..."
    if ! local_sudo -v 2>/dev/null; then
        fail "本机 sudo 密码校验失败"
        exit 1
    fi
    ok "本机 sudo 已缓存"

    info "校验目标机 sudo 密码 ..."
    if ! remote_sudo_validate >/dev/null 2>&1; then
        fail "目标机 sudo 密码校验失败"
        exit 1
    fi
    ok "目标机 sudo 已缓存"

    info "设置本机永不休眠 ..."
    local_sudo pmset -a sleep 0 disksleep 0 displaysleep 0 >/dev/null \
        && ok "本机 sleep/disksleep/displaysleep = 0" \
        || warn "本机 pmset 设置失败"
    caffeinate -dimsu -w "$$" >/dev/null 2>&1 &
    LOCAL_CAFFEINATE_PID="$!"
    ok "本机 caffeinate 已启动 (pid=$LOCAL_CAFFEINATE_PID)"

    info "设置目标机永不休眠 ..."
    remote_sudo_pmset_never_sleep >/dev/null \
        && ok "目标机 sleep/disksleep/displaysleep = 0" \
        || warn "目标机 pmset 设置失败"
    ssh "$TARGET" 'mkdir -p "$HOME/migrate"; if [[ -f "$HOME/migrate/.caffeinate.pid" ]]; then kill "$(cat "$HOME/migrate/.caffeinate.pid")" 2>/dev/null || true; fi; nohup caffeinate -dimsu -t 86400 >/tmp/migrate-caffeinate.log 2>&1 & echo $! > "$HOME/migrate/.caffeinate.pid"'
    ok "目标机 caffeinate 已启动"
}

cleanup_power_preflight() {
    if [[ -n "$LOCAL_CAFFEINATE_PID" ]]; then
        kill "$LOCAL_CAFFEINATE_PID" 2>/dev/null || true
    fi
    if [[ "$DRY_RUN" != "1" && "${MIGRATE_SKIP_POWER_PREFLIGHT:-0}" != "1" ]]; then
        ssh "$TARGET" 'if [[ -f "$HOME/migrate/.caffeinate.pid" ]]; then kill "$(cat "$HOME/migrate/.caffeinate.pid")" 2>/dev/null || true; rm -f "$HOME/migrate/.caffeinate.pid"; fi' 2>/dev/null || true
    fi
}

rsync_major_version() {
    local bin="$1"
    "$bin" --version 2>/dev/null | awk 'NR == 1 && $1 == "rsync" && $2 == "version" {
        split($3, version_parts, ".")
        if (version_parts[1] ~ /^[0-9]+$/) print version_parts[1]
    }'
}

ensure_local_rsync() {
    local current_major=""
    local brew_bin="/opt/homebrew/bin/rsync"

    if [[ -x "$brew_bin" ]]; then
        current_major="$(rsync_major_version "$brew_bin")"
        if [[ "${current_major:-0}" -ge 3 ]]; then
            RSYNC_BIN="$brew_bin"
            RSYNC_BIN_MAJOR="$current_major"
            ok "本机 rsync: $("$RSYNC_BIN" --version | head -n 1)"
            return 0
        fi
    fi

    if command -v rsync >/dev/null 2>&1; then
        RSYNC_BIN="$(command -v rsync)"
        current_major="$(rsync_major_version "$RSYNC_BIN")"
        if [[ "${current_major:-0}" -ge 3 ]]; then
            RSYNC_BIN_MAJOR="$current_major"
            ok "本机 rsync: $("$RSYNC_BIN" --version | head -n 1)"
            return 0
        fi
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        warn "本机 rsync 低于 3.x；dry-run 不自动安装"
        return 0
    fi
    if ! command -v brew >/dev/null 2>&1; then
        warn "本机 rsync 低于 3.x，且 Homebrew 不可用；继续使用 $RSYNC_BIN"
        return 0
    fi

    info "本机 rsync 低于 3.x，使用 Homebrew 安装新版 rsync ..."
    brew install rsync
    current_major=""
    [[ -x "$brew_bin" ]] && current_major="$(rsync_major_version "$brew_bin")"
    if [[ "${current_major:-0}" -ge 3 ]]; then
        RSYNC_BIN="$brew_bin"
        RSYNC_BIN_MAJOR="$current_major"
        ok "本机 rsync 已升级: $("$RSYNC_BIN" --version | head -n 1)"
    else
        warn "本机 rsync 升级后仍不可用；继续使用 $RSYNC_BIN"
    fi
}

remote_rsync_info() {
    ssh "$TARGET" '
        for bin in /opt/homebrew/bin/rsync /usr/local/bin/rsync /usr/bin/rsync; do
            if [[ -x "$bin" ]]; then
                version="$("$bin" --version 2>/dev/null | awk "NR == 1 && \$1 == \"rsync\" && \$2 == \"version\" {print \$3}")"
                major="${version%%.*}"
                printf "%s\t%s\t%s\n" "$bin" "${major:-0}" "$("$bin" --version 2>/dev/null | head -n 1)"
                exit 0
            fi
        done
        exit 1
    '
}

ensure_remote_rsync() {
    local info_line=""
    local bin=""
    local major=""
    local version_line=""

    info_line="$(remote_rsync_info 2>/dev/null || true)"
    if [[ -n "$info_line" ]]; then
        IFS=$'\t' read -r bin major version_line <<< "$info_line"
        if [[ "${major:-0}" -ge 3 ]]; then
            REMOTE_RSYNC_BIN="$bin"
            REMOTE_RSYNC_BIN_MAJOR="$major"
            ok "目标机 rsync: $version_line ($REMOTE_RSYNC_BIN)"
            return 0
        fi
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
        warn "目标机 rsync 低于 3.x；dry-run 不自动安装"
        [[ -n "$bin" ]] && REMOTE_RSYNC_BIN="$bin"
        REMOTE_RSYNC_BIN_MAJOR="${major:-0}"
        return 0
    fi

    info "目标机 rsync 低于 3.x，尝试通过 Homebrew 安装新版 rsync ..."
    if ssh "$TARGET" 'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; command -v brew >/dev/null 2>&1 && brew install rsync'; then
        info_line="$(remote_rsync_info 2>/dev/null || true)"
        if [[ -n "$info_line" ]]; then
            IFS=$'\t' read -r bin major version_line <<< "$info_line"
            if [[ "${major:-0}" -ge 3 ]]; then
                REMOTE_RSYNC_BIN="$bin"
                REMOTE_RSYNC_BIN_MAJOR="$major"
                ok "目标机 rsync 已升级: $version_line ($REMOTE_RSYNC_BIN)"
                return 0
            fi
        fi
    fi

    if [[ -n "$bin" ]]; then
        REMOTE_RSYNC_BIN="$bin"
        REMOTE_RSYNC_BIN_MAJOR="${major:-0}"
    fi
    warn "目标机新版 rsync 不可用；继续使用 $REMOTE_RSYNC_BIN，带空格路径可能不稳定"
}

ensure_rsync_preflight() {
    if [[ "${MIGRATE_SKIP_RSYNC_PREFLIGHT:-0}" == "1" ]]; then
        warn "MIGRATE_SKIP_RSYNC_PREFLIGHT=1，跳过 rsync 版本检查和自动升级"
        return 0
    fi

    info "检查本机/目标机 rsync 版本 ..."
    ensure_local_rsync
    ensure_remote_rsync
}

trap cleanup_power_preflight EXIT INT TERM
start_power_preflight
ensure_rsync_preflight

# --- 导出数据 ---
if [[ "$DRY_RUN" == "1" ]]; then
    info "[dry-run] 跳过本地数据导出"
else
    info "导出数据 ..."
    info "Brewfile 使用手工维护版本: $SCRIPT_DIR/data/Brewfile"

    FINDER_DATA_DIR="$SCRIPT_DIR/data/finder"
    rm -rf "$FINDER_DATA_DIR"
    mkdir -p "$FINDER_DATA_DIR"
    if [[ -f "$HOME/Library/Preferences/com.apple.finder.plist" ]]; then
        cp "$HOME/Library/Preferences/com.apple.finder.plist" \
            "$FINDER_DATA_DIR/com.apple.finder.plist"
        ok "Finder layout 偏好已导出"
    else
        warn "Finder layout 偏好不存在，跳过导出"
    fi
    if [[ -f "$HOME/Library/Preferences/com.apple.sidebarlists.plist" ]]; then
        cp "$HOME/Library/Preferences/com.apple.sidebarlists.plist" \
            "$FINDER_DATA_DIR/com.apple.sidebarlists.plist"
        ok "Finder sidebar plist 已导出"
    fi
    if command -v sfltool &>/dev/null; then
        SFL_OUTPUT="$(sfltool archive 2>&1 || true)"
        SFL_ARCHIVE_PATH="$(printf '%s\n' "$SFL_OUTPUT" | sed -n "s/.*'\(.*\)'.*/\1/p" | tail -n 1)"
        if [[ -n "$SFL_ARCHIVE_PATH" && -d "$SFL_ARCHIVE_PATH/Application Support/com.apple.sharedfilelist" ]]; then
            mkdir -p "$FINDER_DATA_DIR/sharedfilelist"
            "$RSYNC_BIN" -a "$SFL_ARCHIVE_PATH/Application Support/com.apple.sharedfilelist/" \
                "$FINDER_DATA_DIR/sharedfilelist/"
            ok "Finder sidebar shared file lists 已导出"
            rm -rf "$SFL_ARCHIVE_PATH"
        else
            warn "Finder sidebar shared file lists 导出失败"
        fi
    else
        warn "sfltool 不可用，跳过 Finder sidebar shared file lists 导出"
    fi

    KEYBOARD_DATA_DIR="$SCRIPT_DIR/data/keyboard"
    rm -rf "$KEYBOARD_DATA_DIR"
    mkdir -p "$KEYBOARD_DATA_DIR"
    CURRENT_HOST_GLOBAL="$(find "$HOME/Library/Preferences/ByHost" -maxdepth 1 -name '.GlobalPreferences.*.plist' -print -quit 2>/dev/null || true)"
    if [[ -n "$CURRENT_HOST_GLOBAL" && -f "$CURRENT_HOST_GLOBAL" ]]; then
        cp "$CURRENT_HOST_GLOBAL" "$KEYBOARD_DATA_DIR/current-host-global.plist"
        ok "键盘 currentHost 偏好已导出"
    else
        warn "键盘 currentHost 偏好不存在，跳过导出"
    fi

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
RSYNC_OPTS=(-av --rsync-path="$REMOTE_RSYNC_BIN" --exclude-from="$EXCLUDE_FILE")
if [[ "${RSYNC_BIN_MAJOR:-0}" -ge 3 && "${REMOTE_RSYNC_BIN_MAJOR:-0}" -ge 3 ]]; then
    RSYNC_OPTS+=(--secluded-args)
fi
if [[ "$DRY_RUN" == "1" ]]; then
    RSYNC_OPTS+=(--dry-run)
fi
GIT_RSYNC_EXCLUDES=(
    --exclude="node_modules/"
    --exclude="dist/"
    --exclude="release/"
    --exclude="releases/"
    --exclude="build/"
    --exclude="out/"
    --exclude="coverage/"
    --exclude=".next/"
    --exclude=".nuxt/"
    --exclude=".output/"
    --exclude=".svelte-kit/"
    --exclude=".turbo/"
    --exclude=".vite/"
)

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
            "$RSYNC_BIN" "${RSYNC_OPTS[@]}" "$src/" "$(remote_dest "$dest_path/")"
        else
            "$RSYNC_BIN" "${RSYNC_OPTS[@]}" "$src" "$(remote_dest "$dest_path")"
        fi
    fi
}

sync_glob() {
    local pattern="$1"
    local dest_dir="$2"
    local matched=0
    local src=""

    for src in $pattern; do
        [[ -e "$src" ]] || continue
        matched=1
        sync_item "$src" "$dest_dir"
    done

    return 0
}

# === Home 目录 ===
info "同步 Home 目录 ..."
for item in \
    .agents .claude .claude.json .codex .dotfiles .hammerspoon .pi \
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

# === ~/git ===
if [[ -d "$HOME/git" ]]; then
    info "同步 ~/git (排除 node_modules 和构建/release 产物) ..."
    "$RSYNC_BIN" "${RSYNC_OPTS[@]}" "${GIT_RSYNC_EXCLUDES[@]}" --delete --delete-excluded \
        "$HOME/git/" \
        "$(remote_dest "$(remote_home_path "git/")")"
fi

# === zinit ===
if [[ -d "$HOME/.local/share/zinit" ]]; then
    info "同步 zinit ..."
    "$RSYNC_BIN" "${RSYNC_OPTS[@]}" "$HOME/.local/share/zinit/" "$(remote_dest "$(remote_home_path ".local/share/zinit/")")"
fi

# === 字体 ===
info "同步字体 ..."
"$RSYNC_BIN" "${RSYNC_OPTS[@]}" "$HOME/Library/Fonts/" "$(remote_dest "$(remote_home_path "Library/Fonts/")")"
"$RSYNC_BIN" "${RSYNC_OPTS[@]}" "$HOME/Library/FontCollections/" "$(remote_dest "$(remote_home_path "Library/FontCollections/")")" 2>/dev/null || true

# === App 数据 ===
info "同步 App 数据 ..."
sync_item "$HOME/Library/Application Support/Code/User/" \
    "$(remote_home_path "Library/Application Support/Code/User/")"
sync_item "$HOME/Library/Application Support/lazygit/" \
    "$(remote_home_path "Library/Application Support/lazygit/")"
sync_item "$HOME/Library/Application Support/Surge/" \
    "$(remote_home_path "Library/Application Support/Surge/")"
sync_item "$HOME/Library/Application Support/OpenVPN Connect/" \
    "$(remote_home_path "Library/Application Support/OpenVPN Connect/")"
sync_item "$HOME/Library/Application Support/com.DanPristupov.Fork/" \
    "$(remote_home_path "Library/Application Support/com.DanPristupov.Fork/")"
sync_item "$HOME/Library/Application Support/Zed/" \
    "$(remote_home_path "Library/Application Support/Zed/")"
sync_item "$HOME/Library/Application Support/Slack/" \
    "$(remote_home_path "Library/Application Support/Slack/")"
sync_item "$HOME/Library/Application Support/discord/" \
    "$(remote_home_path "Library/Application Support/discord/")"
sync_item "$HOME/Library/Application Support/Torrent Vibe/" \
    "$(remote_home_path "Library/Application Support/Torrent Vibe/")"
sync_item "$HOME/Library/Application Support/IINA/" \
    "$(remote_home_path "Library/Application Support/IINA/")"
sync_item "$HOME/Library/Application Support/com.colliderli.iina/" \
    "$(remote_home_path "Library/Application Support/com.colliderli.iina/")"
sync_item "$HOME/Library/Application Support/com.proxyman.NSProxy/" \
    "$(remote_home_path "Library/Application Support/com.proxyman.NSProxy/")"
sync_item "$HOME/Library/Application Support/Squash/" \
    "$(remote_home_path "Library/Application Support/Squash/")"
sync_item "$HOME/Library/Application Support/abnerworks.Typora/" \
    "$(remote_home_path "Library/Application Support/abnerworks.Typora/")"
sync_item "$HOME/Library/Application Support/typora-user-images/" \
    "$(remote_home_path "Library/Application Support/typora-user-images/")"
sync_item "$HOME/Library/Application Support/Capture One/" \
    "$(remote_home_path "Library/Application Support/Capture One/")"
sync_item "$HOME/Library/Application Support/NeteaseMusic/" \
    "$(remote_home_path "Library/Application Support/NeteaseMusic/")"
sync_item "$HOME/Library/Application Support/Typora/" \
    "$(remote_home_path "Library/Application Support/Typora/")"
sync_item "$HOME/Library/Preferences/wang.jianing.app.OpenInTerminal.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Group Containers/group.wang.jianing.app.OpenInTerminal/" \
    "$(remote_home_path "Library/Group Containers/group.wang.jianing.app.OpenInTerminal/")"
sync_item "$HOME/Library/Containers/wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension/" \
    "$(remote_home_path "Library/Containers/wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension/")"
sync_item "$HOME/Library/Containers/wang.jianing.app.OpenInTerminalHelper/" \
    "$(remote_home_path "Library/Containers/wang.jianing.app.OpenInTerminalHelper/")"
sync_item "$HOME/Library/Application Scripts/group.wang.jianing.app.OpenInTerminal/" \
    "$(remote_home_path "Library/Application Scripts/group.wang.jianing.app.OpenInTerminal/")"
sync_item "$HOME/Library/Application Scripts/wang.jianing.app.OpenInTerminal/" \
    "$(remote_home_path "Library/Application Scripts/wang.jianing.app.OpenInTerminal/")"
sync_item "$HOME/Library/Application Scripts/wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension/" \
    "$(remote_home_path "Library/Application Scripts/wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension/")"
sync_item "$HOME/Library/Application Scripts/wang.jianing.app.OpenInTerminalHelper/" \
    "$(remote_home_path "Library/Application Scripts/wang.jianing.app.OpenInTerminalHelper/")"
sync_item "$HOME/Library/Application Support/com.raycast.shared/" \
    "$(remote_home_path "Library/Application Support/com.raycast.shared/")"
if [[ -d "$HOME/Library/Application Support/com.raycast.macos" ]]; then
    sync_raycast_keychain
    info "同步 Raycast 数据 ..."
    "$RSYNC_BIN" "${RSYNC_OPTS[@]}" \
        "$HOME/Library/Application Support/com.raycast.macos/" \
        "$(remote_dest "$(remote_home_path "Library/Application Support/com.raycast.macos/")")"
fi
sync_item "$HOME/Library/Preferences/com.googlecode.iterm2.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/org.openvpn.client.app.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Keychains/openvpn.keychain-db" \
    "$(remote_home_path "Library/Keychains/")"
sync_item "$HOME/Library/Preferences/com.raycast.macos.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/dev.zed.Zed.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.tinyspeck.slackmacgap.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.hnc.Discord.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/dev.innei.torrentvibe.client.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.luckymarmot.Paw.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.proxyman.NSProxy.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.proxyman.iconappmanager.userdefaults.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.svend.uPic.macos.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.portkiller.app.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.realmacsoftware.squash3.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.apple.pixelmator.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_glob "$HOME/Library/Preferences/com.captureone.*.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.tencent.xinWeChat.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.colliderli.iina.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/com.netease.163music.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Preferences/abnerworks.Typora.plist" \
    "$(remote_home_path "Library/Preferences/")"
sync_item "$HOME/Library/Containers/com.luckymarmot.Paw/" \
    "$(remote_home_path "Library/Containers/com.luckymarmot.Paw/")"
sync_item "$HOME/Library/Containers/com.svend.uPic.macos/" \
    "$(remote_home_path "Library/Containers/com.svend.uPic.macos/")"
sync_item "$HOME/Library/Containers/com.svend.uPic.macos.uPicShareExtension/" \
    "$(remote_home_path "Library/Containers/com.svend.uPic.macos.uPicShareExtension/")"
sync_item "$HOME/Library/Group Containers/group.svend.uPic/" \
    "$(remote_home_path "Library/Group Containers/group.svend.uPic/")"
sync_item "$HOME/Library/Application Scripts/com.luckymarmot.Paw/" \
    "$(remote_home_path "Library/Application Scripts/com.luckymarmot.Paw/")"
sync_item "$HOME/Library/Application Scripts/com.svend.uPic.macos/" \
    "$(remote_home_path "Library/Application Scripts/com.svend.uPic.macos/")"
sync_item "$HOME/Library/Application Scripts/com.svend.uPic.macos.uPicShareExtension/" \
    "$(remote_home_path "Library/Application Scripts/com.svend.uPic.macos.uPicShareExtension/")"
sync_item "$HOME/Library/Application Scripts/group.svend.uPic/" \
    "$(remote_home_path "Library/Application Scripts/group.svend.uPic/")"
sync_glob "$HOME/Library/Containers/com.apple.pixelmator*" \
    "$(remote_home_path "Library/Containers/")"
sync_item "$HOME/Library/Group Containers/com.pixelmator/" \
    "$(remote_home_path "Library/Group Containers/com.pixelmator/")"
sync_glob "$HOME/Library/Application Scripts/com.apple.pixelmator*" \
    "$(remote_home_path "Library/Application Scripts/")"
sync_item "$HOME/Library/Application Scripts/com.pixelmator/" \
    "$(remote_home_path "Library/Application Scripts/com.pixelmator/")"
sync_item "$HOME/Library/Containers/com.tencent.xinWeChat/" \
    "$(remote_home_path "Library/Containers/com.tencent.xinWeChat/")"
sync_item "$HOME/Library/Containers/com.tencent.xinWeChat.WeChatMacShare/" \
    "$(remote_home_path "Library/Containers/com.tencent.xinWeChat.WeChatMacShare/")"
sync_item "$HOME/Library/Group Containers/5A4RE8SF68.com.tencent.xinWeChat/" \
    "$(remote_home_path "Library/Group Containers/5A4RE8SF68.com.tencent.xinWeChat/")"
for ovpn in "$HOME"/*.ovpn; do
    [[ -f "$ovpn" ]] || continue
    sync_item "$ovpn" "$(remote_home_path "$(basename "$ovpn")")"
done

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
            "$RSYNC_BIN" "${RSYNC_OPTS[@]}" --delete "$app_path/" "$(remote_dest "$(remote_home_path "migrate/apps/$line.app/")")"
        else
            warn "  $line.app 不存在，跳过"
        fi
    done < "$RSYNC_APPS_FILE"
fi

# === 迁移脚本本身 ===
info "传输迁移脚本 ..."
"$RSYNC_BIN" "${RSYNC_OPTS[@]}" "$SCRIPT_DIR/" "$(remote_dest "$(remote_home_path "migrate/")")"

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
    for item in .agents .ssh .dotfiles .zshrc .config/zsh .config/ghostty migrate/data/gpg; do
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
