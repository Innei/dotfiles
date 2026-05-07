#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "04" "Brewfile 恢复"

require_brew

BREWFILE="$DATA_DIR/Brewfile"
if [[ -f "$BREWFILE" ]]; then
    info "使用 $BREWFILE ..."
    TMP_BREWFILE="$(mktemp)"
    trap 'rm -f "$TMP_BREWFILE"' EXIT
    awk '!/^mas /' "$BREWFILE" > "$TMP_BREWFILE"
    if grep -q '^mas ' "$BREWFILE"; then
        info "跳过 Brewfile 中的 mas 条目；App Store 应用由 step 11 登录检查后处理"
    fi
    if brew bundle --file="$TMP_BREWFILE"; then
        ok "Brewfile 安装完成"
    else
        warn "Brewfile 部分依赖安装失败；继续执行后续迁移步骤"
        echo "  稍后可单独重试: brew bundle --file='$BREWFILE'"
    fi
else
    fail "未找到 $BREWFILE"
    exit 1
fi
