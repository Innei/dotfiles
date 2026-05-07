#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "08" "全局 npm/pnpm 包"

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

NPM_FILE="$DATA_DIR/npm-global.txt"
PNPM_FILE="$DATA_DIR/pnpm-global.txt"

if [[ -f "$NPM_FILE" ]]; then
    info "npm 全局包列表:"
    cat "$NPM_FILE"
    echo ""
    warn "请按需手动安装，例如:"
    echo "  npm install -g <package>"
    echo ""
fi

if [[ -f "$PNPM_FILE" ]]; then
    info "pnpm 全局包列表:"
    cat "$PNPM_FILE"
    echo ""
    warn "请按需手动安装，例如:"
    echo "  pnpm install -g <package>"
fi
