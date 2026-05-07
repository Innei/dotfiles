#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "02" "Xcode CLI Tools"

# Dry-run: 检查状态并报告，跳过交互式安装
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    if xcode-select -p &>/dev/null; then
        ok "Xcode CLI Tools 已安装: $(xcode-select -p)"
    else
        info "将安装 Xcode CLI Tools (xcode-select --install + 交互确认)"
    fi
    info "完整 Xcode 需从 App Store 手动安装 (很大，建议后装)"
    exit 0
fi

if xcode-select -p &>/dev/null; then
    ok "Xcode CLI Tools 已安装: $(xcode-select -p)"
else
    info "安装 Xcode CLI Tools ..."
    xcode-select --install 2>/dev/null || true
    echo "  ⏳ 请在弹窗中点击「安装」，完成后按回车继续..."
    read -r
    ok "Xcode CLI Tools 安装完成"
fi

# 如果之后需要完整 Xcode (手动装)
echo ""
info "完整 Xcode 需从 App Store 手动安装 (很大，建议后装)"
