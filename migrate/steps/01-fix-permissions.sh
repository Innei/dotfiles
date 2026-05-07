#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "01" "修复权限"

# SSH
if [[ -d ~/.ssh ]]; then
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_ed25519 2>/dev/null || true
    chmod 644 ~/.ssh/id_ed25519.pub ~/.ssh/known_hosts ~/.ssh/config 2>/dev/null || true
    ok "SSH 权限"
else
    warn "~/.ssh 不存在"
fi

# GPG
if [[ -d ~/.gnupg ]]; then
    chmod 700 ~/.gnupg
    chmod 600 ~/.gnupg/*.conf 2>/dev/null || true
    chmod 600 ~/.gnupg/private-keys-v1.d/*.key 2>/dev/null || true
    chmod 644 ~/.gnupg/pubring.kbx ~/.gnupg/trustdb.gpg 2>/dev/null || true
    ok "GPG 权限"
else
    warn "~/.gnupg 不存在"
fi
