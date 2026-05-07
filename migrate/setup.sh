#!/bin/bash
set -euo pipefail

# ============================================
# 新 Mac 初始化编排器
# 用法:
#   ./setup.sh              # 执行全部步骤
#   ./setup.sh 03 09        # 只执行 step 03 和 09
#   ./setup.sh 03-09        # 执行 step 03 到 09
#   ./setup.sh --dry-run    # 干跑模式 (不执行修改操作)
#   ./setup.sh --list       # 列出所有步骤
# ============================================

STEPS_DIR="$(cd "$(dirname "$0")/steps" && pwd)"

# 步骤定义: 编号|文件|描述
STEPS=(
    "00|00-macos-settings.sh|macOS 系统设置"
    "01|01-fix-permissions.sh|修复权限 (SSH/GPG)"
    "02|02-xcode-cli.sh|Xcode CLI Tools"
    "03|03-homebrew.sh|Homebrew"
    "04|04-brewfile.sh|Brewfile 恢复"
    "05|05-dotfiles-symlinks.sh|Dotfile symlinks"
    "06|06-node.sh|Node.js (n)"
    "07|07-pnpm.sh|pnpm / corepack"
    "08|08-npm-global.sh|全局 npm/pnpm 包"
    "09|09-editor-extensions.sh|编辑器扩展"
    "10|10-pkg-apps.sh|.pkg 应用 (GPG/搜狗/OpenVPN)"
    "11|11-install-apps.sh|App 安装 (mas + rsync)"
    "12|12-dock-restore.sh|恢复 Dock 图标"
    "13|13-gpg-import.sh|导入 GPG keys"
    "14|14-clear-quarantine.sh|清理 App quarantine"
    "15|15-notification-prefs.sh|恢复通知权限偏好"
    "16|13-re-auth.sh|重新登录/认证"
)

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

get_step_num()   { echo "$1" | cut -d'|' -f1; }
get_step_file()  { echo "$1" | cut -d'|' -f2; }
get_step_desc()  { echo "$1" | cut -d'|' -f3; }

SUDO_KEEPALIVE_PID=""

stop_sudo_keepalive() {
    if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
}

start_sudo_keepalive() {
    (
        while true; do
            sudo -n true 2>/dev/null || exit
            sleep 60
        done
    ) &
    SUDO_KEEPALIVE_PID="$!"
    trap stop_sudo_keepalive EXIT INT TERM
}

prepare_sudo() {
    [[ "$DRY_RUN" == "1" ]] && return 0

    if sudo -n true 2>/dev/null; then
        echo -e "${GREEN}[ OK ]${NC} sudo credential 已缓存"
        start_sudo_keepalive
        return 0
    fi

    if [[ ! -t 0 ]]; then
        echo -e "${YELLOW}[WARN]${NC} 当前不是交互式 TTY，无法预先读取 sudo 密码"
        echo "  需要 sudo 的步骤会跳过或失败；建议在目标机 Terminal 中运行:"
        echo "  bash ~/migrate/setup.sh ${STEPS_ARGS[*]:-}"
        return 0
    fi

    echo ""
    echo -e "${BOLD}需要管理员权限${NC}"
    echo "请输入当前用户密码以缓存 sudo；后续步骤会自动复用，不会重复询问。"
    if sudo -v; then
        echo -e "${GREEN}[ OK ]${NC} sudo credential 已缓存"
        start_sudo_keepalive
    else
        echo -e "${YELLOW}[WARN]${NC} sudo credential 未缓存；需要 sudo 的步骤会显式提示或跳过"
    fi
}

list_steps() {
    echo -e "${BOLD}可用步骤:${NC}"
    echo ""
    for entry in "${STEPS[@]}"; do
        num=$(get_step_num "$entry")
        desc=$(get_step_desc "$entry")
        printf "  ${CYAN}%s${NC}  %s\n" "$num" "$desc"
    done
    echo ""
    echo "用法:"
    echo "  ./setup.sh              # 全部执行"
    echo "  ./setup.sh 03 09        # 只执行 step 03 和 09"
    echo "  ./setup.sh 03-09        # 执行 step 03 到 09"
    echo "  ./setup.sh --dry-run    # 干跑 (仅打印，不修改)"
    echo "  ./setup.sh --list       # 列出所有步骤"
}

run_step() {
    local num="$1"
    for entry in "${STEPS[@]}"; do
        if [[ "$(get_step_num "$entry")" == "$num" ]]; then
            local file=$(get_step_file "$entry")
            local desc=$(get_step_desc "$entry")
            local script="$STEPS_DIR/$file"
            if [[ ! -f "$script" ]]; then
                echo "Script not found: $script"
                exit 1
            fi
            echo ""
            if [[ "$DRY_RUN" == "1" ]]; then
                echo -e "${YELLOW}▶ Step $num: $desc ${DIM}(dry-run)${NC}"
            else
                echo -e "${GREEN}▶ Step $num: $desc${NC}"
            fi
            echo ""
            DRY_RUN="$DRY_RUN" bash "$script"
            return
        fi
    done
    echo "Unknown step: $num"
    exit 1
}

expand_range() {
    local range="$1"
    local start="${range%-*}"
    local end="${range#*-}"
    local found=false
    for entry in "${STEPS[@]}"; do
        local num=$(get_step_num "$entry")
        if [[ "$num" == "$start" ]]; then found=true; fi
        if $found; then
            echo "$num"
        fi
        if [[ "$num" == "$end" ]]; then found=false; fi
    done
}

DRY_RUN=0
STEPS_ARGS=()
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=1 ;;
        --list|-l)    list_steps; exit 0 ;;
        *)            STEPS_ARGS+=("$arg") ;;
    esac
done

if [[ "$DRY_RUN" == "1" ]]; then
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  ⚠  DRY-RUN 模式 — 不会执行任何修改操作${NC}"
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
fi

prepare_sudo

if [[ ${#STEPS_ARGS[@]} -eq 0 ]]; then
    if [[ "$DRY_RUN" != "1" ]]; then
        echo -e "${BOLD}════════════════════════════════════════${NC}"
        echo -e "${BOLD}  Mac 初始化 - 执行全部步骤${NC}"
        echo -e "${BOLD}════════════════════════════════════════${NC}"
    fi
    for entry in "${STEPS[@]}"; do
        run_step "$(get_step_num "$entry")"
    done
    echo ""
    if [[ "$DRY_RUN" == "1" ]]; then
        echo -e "${YELLOW}════════════════════════════════════════${NC}"
        echo -e "${YELLOW}  Dry-run 完成 — 未执行任何修改${NC}"
        echo -e "${YELLOW}════════════════════════════════════════${NC}"
    else
        echo -e "${GREEN}════════════════════════════════════════${NC}"
        echo -e "${GREEN}  全部完成！建议重启电脑。${NC}"
        echo -e "${GREEN}════════════════════════════════════════${NC}"
    fi

else
    if [[ "$DRY_RUN" != "1" ]]; then
        echo -e "${BOLD}════════════════════════════════════════${NC}"
        echo -e "${BOLD}  Mac 初始化 - 指定步骤${NC}"
        echo -e "${BOLD}════════════════════════════════════════${NC}"
    fi

    for arg in "${STEPS_ARGS[@]}"; do
        if [[ "$arg" == *-* ]]; then
            for s in $(expand_range "$arg"); do
                run_step "$s"
            done
        else
            run_step "$arg"
        fi
    done
fi
