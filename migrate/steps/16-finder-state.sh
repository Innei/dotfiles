#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "16" "恢复 Finder sidebar/layout"

FINDER_DATA_DIR="$DATA_DIR/finder"
SOURCE_FINDER_PLIST="$FINDER_DATA_DIR/com.apple.finder.plist"
SOURCE_SIDEBAR_PLIST="$FINDER_DATA_DIR/com.apple.sidebarlists.plist"
SOURCE_SHARED_DIR="$FINDER_DATA_DIR/sharedfilelist"

TARGET_PREFS_DIR="$HOME/Library/Preferences"
TARGET_SHARED_DIR="$HOME/Library/Application Support/com.apple.sharedfilelist"
BACKUP_ROOT="$HOME/migrate/backups/finder.$(date +%Y%m%d%H%M%S)"

backup_file() {
    local path="$1"
    if [[ -f "$path" ]]; then
        mkdir -p "$BACKUP_ROOT"
        cp -p "$path" "$BACKUP_ROOT/$(basename "$path")"
        ok "已备份 $(basename "$path")"
    fi
}

if [[ ! -d "$FINDER_DATA_DIR" ]]; then
    warn "未找到 Finder 迁移数据: $FINDER_DATA_DIR"
    echo "  在源机器运行 ./migrate.sh <target> 会自动导出 Finder sidebar/layout"
    exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    _dry "mkdir -p $TARGET_PREFS_DIR $TARGET_SHARED_DIR"
    [[ -f "$SOURCE_FINDER_PLIST" ]] && _dry "cp $SOURCE_FINDER_PLIST $TARGET_PREFS_DIR/com.apple.finder.plist"
    [[ -f "$SOURCE_SIDEBAR_PLIST" ]] && _dry "cp $SOURCE_SIDEBAR_PLIST $TARGET_PREFS_DIR/com.apple.sidebarlists.plist"
    [[ -d "$SOURCE_SHARED_DIR" ]] && _dry "rsync -a $SOURCE_SHARED_DIR/ $TARGET_SHARED_DIR/"
    _dry "killall Finder cfprefsd sharedfilelistd"
    ok "Finder sidebar/layout dry-run 完成"
    exit 0
fi

mkdir -p "$TARGET_PREFS_DIR" "$TARGET_SHARED_DIR"

if [[ -f "$SOURCE_FINDER_PLIST" ]]; then
    if plutil -lint "$SOURCE_FINDER_PLIST" >/dev/null; then
        backup_file "$TARGET_PREFS_DIR/com.apple.finder.plist"
        cp -p "$SOURCE_FINDER_PLIST" "$TARGET_PREFS_DIR/com.apple.finder.plist"
        chmod 600 "$TARGET_PREFS_DIR/com.apple.finder.plist"
        ok "已恢复 Finder layout 偏好"
    else
        warn "Finder plist 无效，跳过: $SOURCE_FINDER_PLIST"
    fi
else
    warn "未找到 Finder layout plist: $SOURCE_FINDER_PLIST"
fi

if [[ -f "$SOURCE_SIDEBAR_PLIST" ]]; then
    if plutil -lint "$SOURCE_SIDEBAR_PLIST" >/dev/null; then
        backup_file "$TARGET_PREFS_DIR/com.apple.sidebarlists.plist"
        cp -p "$SOURCE_SIDEBAR_PLIST" "$TARGET_PREFS_DIR/com.apple.sidebarlists.plist"
        chmod 600 "$TARGET_PREFS_DIR/com.apple.sidebarlists.plist"
        ok "已恢复 Finder sidebar plist"
    else
        warn "Finder sidebar plist 无效，跳过: $SOURCE_SIDEBAR_PLIST"
    fi
fi

if [[ -d "$SOURCE_SHARED_DIR" ]]; then
    shared_count="$(find "$SOURCE_SHARED_DIR" -type f -name "*.sfl*" | wc -l | tr -d ' ')"
    if [[ "${shared_count:-0}" -gt 0 ]]; then
        mkdir -p "$BACKUP_ROOT/sharedfilelist"
        cp -pR "$TARGET_SHARED_DIR/." "$BACKUP_ROOT/sharedfilelist/" 2>/dev/null || true
        rsync -a "$SOURCE_SHARED_DIR/" "$TARGET_SHARED_DIR/"
        find "$TARGET_SHARED_DIR" -type f -name "*.sfl*" -exec chmod 600 {} + 2>/dev/null || true
        ok "已恢复 Finder sidebar shared file lists (${shared_count} 个)"
    else
        warn "Finder shared file list 目录为空: $SOURCE_SHARED_DIR"
    fi
else
    warn "未找到 Finder shared file list 数据: $SOURCE_SHARED_DIR"
fi

killall Finder cfprefsd sharedfilelistd 2>/dev/null || true
ok "已重启 Finder / cfprefsd / sharedfilelistd"

warn "Finder sidebar/layout 通常会立即刷新；如果 sidebar 顺序未完全出现，重新登录后再确认"
