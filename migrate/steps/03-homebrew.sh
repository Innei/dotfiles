#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "03" "Homebrew"

if has brew; then
    ok "Homebrew 已安装: $(brew --version | head -1)"
else
    info "安装 Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # arm64 Mac 需要配置 PATH
    if [[ $(uname -m) == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo ""
        info "检测到 Apple Silicon，写入 PATH 到 ~/.zprofile ..."
        if ! grep -q '/opt/homebrew/bin/brew' ~/.zprofile 2>/dev/null; then
            echo '' >> ~/.zprofile
            echo '# Homebrew' >> ~/.zprofile
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
    fi

    ensure_brew
    if ! has brew; then
        fail "Homebrew 安装后仍不可用"
        exit 1
    fi
    ok "Homebrew 安装完成"
fi
