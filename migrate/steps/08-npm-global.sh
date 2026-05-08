#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "08" "pnpm global 包"

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH"

NPM_FILE="$DATA_DIR/npm-global.txt"
PNPM_FILE="$DATA_DIR/pnpm-global.txt"

extract_packages() {
    local file="$1"
    awk '/── / {sub(/^.*── /, ""); print $1}' "$file" | sed '/^$/d'
}

install_pnpm_packages() {
    local package=""
    local failures=0

    for package in "$@"; do
        info "  pnpm $package"
        if pnpm add -g "$package"; then
            ok "  ✓ $package"
        else
            warn "  ✗ $package"
            failures=$((failures + 1))
        fi
    done

    return "$failures"
}

pnpm_packages=()
for package_file in "$NPM_FILE" "$PNPM_FILE"; do
    [[ -f "$package_file" ]] || continue
    while IFS= read -r package; do
        [[ -n "$package" ]] && pnpm_packages+=("$package")
    done < <(extract_packages "$package_file")
done

if [[ "${#pnpm_packages[@]}" -gt 0 ]]; then
    if has pnpm; then
        mkdir -p "$PNPM_HOME"
        info "使用 pnpm global 安装包 (${#pnpm_packages[@]} 个，包含原 npm-global 列表迁移) ..."
        install_pnpm_packages "${pnpm_packages[@]}" || warn "部分 pnpm global 包安装失败"
    else
        warn "pnpm 不可用，跳过 global 包"
    fi
else
    warn "未从 $NPM_FILE / $PNPM_FILE 解析到 global 包"
fi
