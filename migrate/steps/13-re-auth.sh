#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "16" "重新登录 / 认证"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

OPEN_APPS="${RE_AUTH_OPEN:-0}"
for arg in "$@"; do
    case "$arg" in
        --open) OPEN_APPS=1 ;;
        --no-open) OPEN_APPS=0 ;;
    esac
done

PENDING=0

section() {
    echo ""
    info "$1"
}

pass() {
    ok "$1"
}

todo() {
    warn "$1"
    PENDING=$((PENDING + 1))
}

note() {
    echo "  $*"
}

app_exists() {
    local name="$1"
    [[ -d "/Applications/$name.app" || -d "$HOME/Applications/$name.app" ]]
}

open_app() {
    local name="$1"
    if [[ "$OPEN_APPS" != "1" ]]; then
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        _dry "open -a '$name'"
        return 0
    fi
    open -a "$name" >/dev/null 2>&1 || true
}

open_url() {
    local url="$1"
    if [[ "$OPEN_APPS" != "1" ]]; then
        return 0
    fi
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        _dry "open '$url'"
        return 0
    fi
    open "$url" >/dev/null 2>&1 || true
}

has_file_match() {
    local pattern="$1"
    local file
    for file in $pattern; do
        [[ -e "$file" ]] && return 0
    done
    return 1
}

section "本步骤不能代替人工登录；会自动检查本地状态并列出剩余操作。"
if [[ "$OPEN_APPS" == "1" ]]; then
    note "已启用打开 App/设置页。"
else
    note "如需同时打开相关 App: RE_AUTH_OPEN=1 bash migrate/steps/13-re-auth.sh"
fi

section "账号与 App"

if app_exists "1Password"; then
    if has op && op whoami >/dev/null 2>&1; then
        pass "1Password CLI 已登录"
    else
        todo "1Password 需要确认账号登录"
        note "打开 1Password 后完成账号登录；CLI 可用时运行: op signin"
        open_app "1Password"
    fi
else
    todo "未检测到 1Password.app"
fi

if app_exists "Surge"; then
    if [[ -d "$HOME/Library/Application Support/Surge" || -f "$HOME/Library/Preferences/com.nssurge.surge-mac.plist" ]]; then
        pass "Surge 已安装，检测到本地配置痕迹"
    else
        todo "Surge 已安装，但未检测到本地配置"
        note "打开 Surge 后导入配置或登录账号"
    fi
    open_app "Surge"
else
    todo "未检测到 Surge.app"
fi

if has gh; then
    if gh auth status -h github.com >/dev/null 2>&1; then
        pass "GitHub CLI 已认证"
    else
        todo "GitHub CLI 未认证"
        note "运行: gh auth login -h github.com -w"
    fi
else
    todo "未检测到 gh 命令"
fi

if has npm; then
    if [[ -f "$HOME/.npmrc" ]] && grep -Eq '(_authToken|//.+:_authToken)=' "$HOME/.npmrc"; then
        pass "npm token 已存在"
        note "如需验证 token 是否仍有效，手动运行: npm whoami"
    else
        todo "npm 未登录或 ~/.npmrc 没有 token"
        note "运行: npm login"
    fi
else
    todo "未检测到 npm 命令"
fi

if [[ -f "$HOME/.wakatime.cfg" ]] && grep -Eq '^api_key[[:space:]]*=[[:space:]]*.+' "$HOME/.wakatime.cfg"; then
    pass "WakaTime API key 已存在"
else
    todo "WakaTime API key 未检测到"
    note "检查 ~/.wakatime.cfg，或在编辑器扩展内重新登录"
fi

if app_exists "Raycast"; then
    if [[ -d "$HOME/Library/Application Support/com.raycast.macos" ]]; then
        pass "Raycast 已安装，检测到本地数据目录"
    else
        todo "Raycast 已安装，但未检测到同步数据"
        note "打开 Raycast 后登录同步扩展"
    fi
    open_app "Raycast"
else
    todo "未检测到 Raycast.app"
fi

section "SSH / GPG / 开发凭据"

if has_file_match "$HOME/.ssh/*.pub"; then
    pass "检测到 SSH public key"
    note "确认这些公钥已添加到 GitHub/GitLab/服务器:"
    for key in "$HOME"/.ssh/*.pub; do
        [[ -e "$key" ]] || continue
        note "- $key"
    done
else
    todo "未检测到 SSH public key"
    note "需要生成或从源机迁移 SSH key，然后添加到 GitHub/GitLab 等服务"
fi

if [[ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
    pass "1Password SSH agent socket 已存在"
else
    todo "1Password SSH agent 未检测到"
    note "在 1Password 设置中启用 SSH Agent，并确认 ~/.ssh/config 使用 IdentityAgent"
fi

if has gpg; then
    if GPG_SECRET_KEYS_OUTPUT="$(gpg --list-secret-keys 2>&1)"; then
        GPG_SECRET_KEYS_STATUS=0
    else
        GPG_SECRET_KEYS_STATUS=$?
    fi
    if [[ "$GPG_SECRET_KEYS_STATUS" -eq 0 ]] && grep -q '^sec' <<<"$GPG_SECRET_KEYS_OUTPUT"; then
        pass "GPG secret key 已存在"
        note "建议手动测试签名: echo test | gpg --clearsign"
    elif [[ "$GPG_SECRET_KEYS_STATUS" -ne 0 ]]; then
        todo "无法读取 GPG keyring，不能确认 secret key 状态"
        note "$GPG_SECRET_KEYS_OUTPUT"
    else
        todo "GPG secret key 未检测到"
        note "先运行 setup step 13 导入 GPG keys"
    fi
else
    todo "未检测到 gpg 命令"
fi

section "运行环境"

if app_exists "OrbStack"; then
    if has docker && docker context inspect orbstack >/dev/null 2>&1; then
        pass "OrbStack Docker context 已存在"
    else
        todo "OrbStack 需要首次启动并初始化 Docker context"
        note "打开 OrbStack 后等待初始化完成"
    fi
    open_app "OrbStack"
else
    todo "未检测到 OrbStack.app"
fi

if app_exists "Hammerspoon"; then
    if [[ -f "$HOME/.hammerspoon/init.lua" ]]; then
        if pgrep -x Hammerspoon >/dev/null 2>&1; then
            pass "Hammerspoon 配置存在且进程正在运行"
        else
            pass "Hammerspoon 配置已复制"
            note "打开 Hammerspoon 并检查 Console 是否有配置错误"
            open_app "Hammerspoon"
        fi
    else
        todo "未检测到 ~/.hammerspoon/init.lua"
    fi
else
    todo "未检测到 Hammerspoon.app"
fi

section "登录项"
note "请在 系统设置 → 通用 → 登录项 中确认:"
note "- Hammerspoon"
note "- CleanShot X"
note "- OpenVPN Connect"
note "- Raycast"
note "- Typeless"
note "- Bob"
open_url "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"

echo ""
if [[ "$PENDING" -eq 0 ]]; then
    ok "重新登录 / 认证检查完成，未发现待处理项"
else
    warn "重新登录 / 认证检查完成，仍有 $PENDING 项需要人工确认"
fi
