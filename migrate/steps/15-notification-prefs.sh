#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "15" "恢复通知权限偏好"

SOURCE_PLIST="$DATA_DIR/notification-prefs.plist"
TARGET_PLIST="$HOME/Library/Preferences/com.apple.ncprefs.plist"
BACKUP_PLIST="$TARGET_PLIST.backup.$(date +%Y%m%d%H%M%S)"
FILTERED_PLIST=""

summarize_notifications() {
    local plist="$1"
    /usr/bin/python3 - "$plist" <<'PY'
import plistlib
import sys

path = sys.argv[1]
try:
    with open(path, "rb") as f:
        data = plistlib.load(f)
except Exception as exc:
    print(f"无法读取通知偏好: {exc}")
    raise SystemExit(0)

apps = data.get("apps", [])
user_apps = [
    app for app in apps
    if isinstance(app, dict) and str(app.get("path", "")).startswith("/Applications/")
]
print(f"通知偏好条目: {len(apps)} 个，其中 /Applications App: {len(user_apps)} 个")
for app in sorted(user_apps, key=lambda item: item.get("bundle-id", "")):
    bundle_id = app.get("bundle-id", "<unknown>")
    auth = app.get("auth", "<unset>")
    path = app.get("path", "")
    print(f"  {bundle_id} auth={auth} path={path}")
PY
}

filter_notifications() {
    local source="$1"
    local target="$2"
    /usr/bin/python3 - "$source" "$target" <<'PY'
import os
import plistlib
import sys

source, target = sys.argv[1:3]

def app_root(path):
    if not path.startswith("/Applications/"):
        return None
    rel = path[len("/Applications/"):]
    marker = ".app"
    idx = rel.find(marker)
    if idx == -1:
        return None
    return "/Applications/" + rel[:idx + len(marker)]

def normalize_app_path(app):
    path = str(app.get("path", ""))
    if not path:
        return
    if path.startswith("/System/") or path.startswith("/Library/"):
        return
    root = app_root(path)
    if not root or os.path.exists(path):
        return

    # Apps such as Chrome embed notification helper apps under versioned paths.
    # Preserve the source bundle-id state but rewrite the path to the target version.
    wanted = os.path.basename(path)
    if wanted.endswith(".app") and os.path.isdir(root):
        for dirpath, dirnames, _filenames in os.walk(root):
            if wanted in dirnames:
                app["path"] = os.path.join(dirpath, wanted)
                return

def should_keep(app):
    path = str(app.get("path", ""))
    if not path:
        return True
    if path.startswith("/System/") or path.startswith("/Library/"):
        return True
    root = app_root(path)
    if root:
        return os.path.isdir(root)
    return os.path.exists(path)

with open(source, "rb") as f:
    data = plistlib.load(f)

apps = data.get("apps", [])
if isinstance(apps, list):
    filtered = []
    for app in apps:
        if isinstance(app, dict):
            normalize_app_path(app)
            if not should_keep(app):
                continue
        filtered.append(app)
    data["apps"] = filtered

with open(target, "wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)

print(f"保留通知偏好条目: {len(data.get('apps', []))}/{len(apps)}")
PY
}

if [[ ! -f "$SOURCE_PLIST" ]]; then
    warn "未找到通知偏好数据: $SOURCE_PLIST"
    echo "  在源机器运行 ./migrate.sh <target> 会自动导出该文件"
    exit 0
fi

if ! plutil -lint "$SOURCE_PLIST" >/dev/null; then
    warn "通知偏好 plist 无效，跳过恢复: $SOURCE_PLIST"
    exit 0
fi

info "将源机器通知权限偏好恢复到当前用户"
summarize_notifications "$SOURCE_PLIST"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    _dry "filter $SOURCE_PLIST to installed apps on target"
    _dry "mkdir -p $(dirname "$TARGET_PLIST")"
    if [[ -f "$TARGET_PLIST" ]]; then
        _dry "cp $TARGET_PLIST $BACKUP_PLIST"
    fi
    _dry "cp filtered notification prefs $TARGET_PLIST"
    _dry "chmod 600 $TARGET_PLIST"
    _dry "killall usernoted NotificationCenter cfprefsd"
    ok "通知权限偏好 dry-run 完成"
    exit 0
fi

FILTERED_PLIST="$(mktemp /tmp/notification-prefs.XXXXXX.plist)"
trap '[[ -n "$FILTERED_PLIST" ]] && rm -f "$FILTERED_PLIST"' EXIT
filter_notifications "$SOURCE_PLIST" "$FILTERED_PLIST"

mkdir -p "$(dirname "$TARGET_PLIST")"
if [[ -f "$TARGET_PLIST" ]]; then
    cp "$TARGET_PLIST" "$BACKUP_PLIST"
    ok "已备份当前通知偏好: $BACKUP_PLIST"
fi

cp "$FILTERED_PLIST" "$TARGET_PLIST"
chmod 600 "$TARGET_PLIST"
ok "已恢复通知权限偏好"

killall usernoted NotificationCenter cfprefsd 2>/dev/null || true
ok "已重启通知相关用户进程"

warn "这会恢复源机器已有 bundle-id 的 allow/deny 状态；全新 App 首次请求通知时仍可能由 macOS 弹出授权询问"
