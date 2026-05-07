#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "12" "恢复 Dock 图标"

DOCK_FILE="$DATA_DIR/dock-layout.json"

# Dry-run: 读取布局并报告，跳过 defaults write / killall
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    if [[ ! -f "$DOCK_FILE" ]]; then
        fail "未找到 $DOCK_FILE"
        exit 1
    fi
    info "将执行以下 Dock 操作:"
    echo "  1. defaults delete com.apple.dock persistent-apps"
    echo "  2. defaults delete com.apple.dock persistent-others"
    echo "  3. 按 dock-layout.json 写入图标"
    echo "  4. killall Dock"
    echo ""
    /usr/bin/python3 -c "
import json
with open('$DOCK_FILE') as f:
    data = json.load(f)
apps = data.get('apps', [])
others = data.get('others', [])
print(f'  应用图标: {len(apps)} 个')
for app in apps:
    print(f'    - {app[\"label\"]}')
print(f'  其他项目: {len(others)} 个')
for item in others:
    print(f'    - {item[\"label\"]}')
" 2>/dev/null || warn "无法解析 $DOCK_FILE"
    exit 0
fi

if [[ ! -f "$DOCK_FILE" ]]; then
    fail "未找到 $DOCK_FILE"
    exit 1
fi

info "生成 Dock plist ..."
/usr/bin/python3 - "$DOCK_FILE" <<'PY'
import json
import os
import plistlib
import subprocess
import sys
import tempfile
from pathlib import Path

dock_file = sys.argv[1]
with open(dock_file) as f:
    layout = json.load(f)

try:
    exported = subprocess.run(
        ["defaults", "export", "com.apple.dock", "-"],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    ).stdout
    dock = plistlib.loads(exported) if exported else {}
except Exception:
    dock = {}

def resolve_path(raw):
    return os.path.expandvars(raw.replace("$HOME", os.path.expanduser("~")))

def file_url(path):
    return Path(path).resolve().as_uri() + "/"

apps = []
others = []
missing = []

for app in layout.get("apps", []):
    label = app["label"]
    path = resolve_path(app["path"])
    if not os.path.isdir(path):
        missing.append(f"{label} ({path})")
        continue
    apps.append({
        "tile-data": {
            "file-data": {
                "_CFURLString": file_url(path),
                "_CFURLStringType": 15,
            },
            "file-label": label,
            "file-type": 41,
        },
        "tile-type": "file-tile",
    })
    print(f"  OK app: {label}")

for item in layout.get("others", []):
    label = item["label"]
    path = resolve_path(item["path"])
    if not os.path.exists(path):
        missing.append(f"{label} ({path})")
        continue
    others.append({
        "tile-data": {
            "arrangement": 2,
            "displayas": 0,
            "file-data": {
                "_CFURLString": file_url(path),
                "_CFURLStringType": 15,
            },
            "file-label": label,
            "file-type": 2,
            "preferreditemsize": -1,
            "showas": 1,
        },
        "tile-type": "directory-tile",
    })
    print(f"  OK other: {label}")

dock["persistent-apps"] = apps
dock["persistent-others"] = others

with tempfile.NamedTemporaryFile("wb", delete=False, suffix=".plist") as f:
    plistlib.dump(dock, f, fmt=plistlib.FMT_XML)
    tmp = f.name

try:
    subprocess.run(["defaults", "import", "com.apple.dock", tmp], check=True)
finally:
    os.unlink(tmp)

if missing:
    print("  Missing items skipped:", file=sys.stderr)
    for item in missing:
        print(f"    - {item}", file=sys.stderr)
PY

echo ""
info "重启 Dock 使生效 ..."
killall Dock 2>/dev/null || true
ok "Dock 图标恢复完成"
