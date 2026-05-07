#!/bin/bash
set -euo pipefail

# ============================================
# 公共函数库 (被各 step source)
# ============================================

MIGRATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$MIGRATE_DIR/data"
STEP_DIR="$MIGRATE_DIR/steps"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()      { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail()    { echo -e "${RED}[FAIL]${NC} $*"; }

step_header() {
    echo ""
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW} Step $1: $2 ${DIM}(dry-run)${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN} Step $1: $2${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
}

# 检查命令是否存在
has() { command -v "$1" &>/dev/null; }

# 确保 brew 可用 (arm64 Mac 上需要)
ensure_brew() {
    if ! has brew; then
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

require_brew() {
    ensure_brew
    if ! has brew; then
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            info "Homebrew 当前不可用；dry-run 继续展示后续计划"
            return 0
        fi
        fail "Homebrew 不可用，请先成功运行 step 03"
        return 1
    fi
}

# ============================================
# Dry-run 支持
# 设置 DRY_RUN=1 后，破坏性命令将被拦截并仅打印到 stderr
# ============================================

DRY_RUN="${DRY_RUN:-0}"

if [[ "$DRY_RUN" == "1" ]]; then
    # 干跑日志 (输出到 stderr，避免污染 stdout 管道)
    _dry() { echo -e "\033[1;33m[DRY]\033[0m $*" >&2; }

    # --- 系统设置 ---
    defaults() {
        case "$1" in
            write|delete) _dry "defaults $*" ;;
            *) command defaults "$@" ;;
        esac
    }
    sudo()       { _dry "sudo $*"; return 0; }
    chmod()      { _dry "chmod $*"; return 0; }
    osascript()  { _dry "osascript $*"; return 0; }
    killall()    { _dry "killall $*"; return 0; }

    # --- 文件操作 ---
    mkdir()  { _dry "mkdir $*"; return 0; }
    cp()     { _dry "cp $*"; return 0; }
    unzip()  { _dry "unzip $*"; return 0; }

    # --- 下载 / 安装 ---
    curl()      { _dry "curl $*"; return 0; }
    hdiutil()   { _dry "hdiutil $*"; return 0; }
    installer() { _dry "installer $*"; return 0; }

    # --- 包管理器 (读操作放行) ---
    brew() {
        case "$1" in
            install|bundle|upgrade|reinstall|tap)
                _dry "brew $*"
                ;;
            *)
                command brew "$@"
                ;;
        esac
    }
    corepack() { _dry "corepack $*"; return 0; }

    # --- App / 扩展安装 (读操作放行) ---
    xcode-select() {
        case "$1" in
            --install) _dry "xcode-select --install"; return 0 ;;
            *) command xcode-select "$@" ;;
        esac
    }
    mas() {
        case "$1" in
            install) _dry "mas $*"; return 0 ;;
            *) command mas "$@" ;;
        esac
    }
    code() {
        case "$1" in
            --install-extension) _dry "code $*"; return 0 ;;
            *) command code "$@" ;;
        esac
    }

    # --- dotfiles 工具 ---
    rcup() { _dry "rcup $*"; return 0; }
fi
