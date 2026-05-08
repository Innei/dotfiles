#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "02" "Xcode CLI Tools"

# Dry-run: 检查状态并报告，跳过交互式安装
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    if xcode-select -p &>/dev/null; then
        ok "Xcode CLI Tools 已安装: $(xcode-select -p)"
    else
        info "将通过 softwareupdate 非交互安装 Xcode CLI Tools"
    fi
    info "完整 Xcode 需从 App Store 手动安装 (很大，建议后装)"
    exit 0
fi

if xcode-select -p &>/dev/null; then
    ok "Xcode CLI Tools 已安装: $(xcode-select -p)"
else
    info "安装 Xcode CLI Tools ..."
    TOUCH_FILE="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo touch "$TOUCH_FILE"
    trap 'sudo rm -f "$TOUCH_FILE" 2>/dev/null || true' EXIT

    CLT_LABEL="$(softwareupdate -l 2>&1 \
        | awk -F': ' '/Label: Command Line Tools/{label=$2} END{print label}')"

    if [[ -z "$CLT_LABEL" ]]; then
        fail "softwareupdate 未找到可安装的 Command Line Tools"
        echo "  可稍后在目标机手动运行: xcode-select --install"
        exit 1
    fi

    info "安装: $CLT_LABEL"
    sudo softwareupdate -i "$CLT_LABEL" --verbose

    if xcode-select -p &>/dev/null; then
        ok "Xcode CLI Tools 安装完成: $(xcode-select -p)"
    else
        fail "Xcode CLI Tools 安装后仍不可用"
        exit 1
    fi
fi

# 如果之后需要完整 Xcode (手动装)
echo ""
info "完整 Xcode 需从 App Store 手动安装 (很大，建议后装)"
