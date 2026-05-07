#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "05" "Dotfiles symlinks"

if has rcup; then
    info "执行 rcup ..."
    rcup
    ok "dotfile symlinks 恢复完成"
else
    warn "rcm (rcup) 未安装，尝试 brew 安装 ..."
    require_brew
    if ! brew list rcm &>/dev/null; then
        brew install rcm
    fi

    if has rcup; then
        rcup
        ok "dotfile symlinks 恢复完成"
    else
        fail "rcm 不可用，请手动创建 symlinks"
        exit 1
    fi
fi
