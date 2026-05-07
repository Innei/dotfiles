#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "07" "pnpm / corepack"

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"
ensure_brew

if has node; then
    if has corepack; then
        corepack enable
        corepack prepare pnpm@latest --activate
    elif ! has pnpm; then
        require_brew
        info "corepack 不可用，改用 Homebrew 安装 pnpm ..."
        brew install pnpm
    fi

    if has pnpm; then
        ok "pnpm $(pnpm --version) 就绪"
    else
        fail "pnpm 未安装成功"
        exit 1
    fi
elif [[ "${DRY_RUN:-0}" == "1" ]]; then
    info "Node.js 当前未安装；真实执行时请先运行 step 06"
    corepack enable
    corepack prepare pnpm@latest --activate
    ok "pnpm 将通过 corepack 启用"
else
    fail "Node.js 未安装，请先运行 step 06"
    exit 1
fi
