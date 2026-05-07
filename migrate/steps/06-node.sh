#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "06" "Node.js (n)"

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

if has node; then
    ok "Node $(node -v) 已安装"
else
    info "安装 n + Node.js ..."
    curl -L https://git.io/n-install | bash -s -- -y

    # 写入 shell 配置
    if ! grep -q 'N_PREFIX' ~/.zshrc 2>/dev/null && ! grep -q 'N_PREFIX' ~/.config/zsh/*.zsh 2>/dev/null; then
        warn "请确保 shell 配置中有:"
        echo '  export N_PREFIX="$HOME/.n"'
        echo '  export PATH="$N_PREFIX/bin:$PATH"'
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        ok "Node.js 将通过 n-install 安装"
        exit 0
    fi

    ok "Node $(node -v) 安装完成"
fi
