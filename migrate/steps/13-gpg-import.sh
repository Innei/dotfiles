#!/bin/bash
source "$(dirname "$0")/lib.sh"
step_header "13" "导入 GPG keys"

GPG_DIR="$DATA_DIR/gpg"
PUBLIC_KEYS="$GPG_DIR/public.asc"
SECRET_KEYS="$GPG_DIR/secret.asc"
OWNERTRUST="$GPG_DIR/ownertrust.txt"

export GNUPGHOME="${GNUPGHOME:-$HOME/.gnupg}"
export PATH="/usr/local/MacGPG2/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

if ! has gpg; then
    warn "gpg 命令不可用；请先安装 GPG Suite 或 gnupg"
    exit 0
fi

if [[ ! -d "$GPG_DIR" ]]; then
    warn "未找到 GPG 导出目录: $GPG_DIR"
    echo "  在源机运行 ./migrate.sh <target> 会导出 public/secret/ownertrust"
    exit 0
fi

mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    [[ -f "$PUBLIC_KEYS" ]] && _dry "gpg --import $PUBLIC_KEYS"
    [[ -f "$SECRET_KEYS" ]] && _dry "gpg --import $SECRET_KEYS"
    [[ -f "$OWNERTRUST" ]] && _dry "gpg --import-ownertrust $OWNERTRUST"
    ok "GPG key 导入 dry-run 完成"
    exit 0
fi

IMPORTED=0

if [[ -s "$PUBLIC_KEYS" ]]; then
    info "导入 GPG public keys ..."
    gpg --batch --import "$PUBLIC_KEYS"
    IMPORTED=1
else
    warn "未找到 public keys: $PUBLIC_KEYS"
fi

if [[ -s "$SECRET_KEYS" ]]; then
    info "导入 GPG secret keys ..."
    chmod 600 "$SECRET_KEYS"
    gpg --batch --import "$SECRET_KEYS"
    IMPORTED=1
else
    warn "未找到 secret keys: $SECRET_KEYS"
fi

if [[ -s "$OWNERTRUST" ]]; then
    info "导入 GPG ownertrust ..."
    gpg --batch --import-ownertrust "$OWNERTRUST"
else
    warn "未找到 ownertrust: $OWNERTRUST"
fi

chmod 700 "$GNUPGHOME"
find "$GNUPGHOME" -type d -exec chmod 700 {} + 2>/dev/null || true
find "$GNUPGHOME" -type f -exec chmod 600 {} + 2>/dev/null || true

if [[ "$IMPORTED" == "1" ]]; then
    ok "GPG keys 导入完成"
    info "当前 secret keys:"
    gpg --list-secret-keys --keyid-format LONG || true
else
    warn "没有导入任何 GPG key"
fi
