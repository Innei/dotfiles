#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "09" "编辑器扩展"

ensure_brew

# VS Code
VSCODE_FILE="$DATA_DIR/vscode-extensions.txt"
EDITOR_CLI=""
if has code; then
    EDITOR_CLI="code"
elif has cursor; then
    EDITOR_CLI="cursor"
elif has Cursor; then
    EDITOR_CLI="Cursor"
fi

if [[ -f "$VSCODE_FILE" ]] && [[ -n "$EDITOR_CLI" ]]; then
    TOTAL=$(wc -l < "$VSCODE_FILE" | tr -d ' ')
    info "使用 $EDITOR_CLI 安装编辑器扩展 ($TOTAL 个) ..."
    while IFS= read -r ext; do
        "$EDITOR_CLI" --install-extension "$ext" 2>/dev/null && ok "  ✓ $ext" || warn "  ✗ $ext"
    done < "$VSCODE_FILE"
else
    if [[ ! -f "$VSCODE_FILE" ]]; then
        warn "未找到 $VSCODE_FILE"
    fi
    if [[ -z "$EDITOR_CLI" ]]; then
        warn "VS Code/Cursor CLI 不可用"
    fi
fi
