#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "14" "清理 App quarantine"

clear_quarantine() {
    local path="$1"
    [[ -e "$path" ]] || return 0

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        _dry "xattr -r -d com.apple.quarantine $path"
        return 0
    fi

    if xattr -lr "$path" 2>/dev/null | grep -q 'com.apple.quarantine'; then
        info "清理 $path"
        if xattr -r -d com.apple.quarantine "$path" 2>/dev/null; then
            return 0
        elif sudo -n true 2>/dev/null; then
            sudo xattr -r -d com.apple.quarantine "$path"
        else
            warn "需要 sudo 清理 quarantine: sudo xattr -r -d com.apple.quarantine '$path'"
            return 0
        fi

        if xattr -lr "$path" 2>/dev/null | grep -q 'com.apple.quarantine'; then
            warn "$path 仍有 quarantine xattr"
        fi
    fi
}

for app in /Applications/*.app; do
    clear_quarantine "$app"
done

if [[ -d "$HOME/migrate/apps" ]]; then
    for app in "$HOME"/migrate/apps/*.app; do
        clear_quarantine "$app"
    done
fi

ok "App quarantine 清理完成"
