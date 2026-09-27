#!/usr/bin/env bash
set -euo pipefail

# Roda em build-time, quando /home ainda é um symlink pendurado pra /var/home
# (só existe de verdade no primeiro boot do ostree) — não dá pra symlinkar
# direto pra dentro de $HOME aqui. Em vez disso, copiamos o conteúdo pra um
# lugar permanente da imagem (/usr/share) e o link-dotfiles.sh (rodado por
# um systemd --user unit no login) cria os symlinks reais em $HOME.

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="/usr/share/citadel-dotfiles"

rm -rf "$DEST"
mkdir -p "$DEST"

[[ -d "$MODULE_DIR/.config" ]] && cp -r "$MODULE_DIR/.config" "$DEST/"
[[ -d "$MODULE_DIR/.local" ]] && cp -r "$MODULE_DIR/.local" "$DEST/"
[[ -f "$MODULE_DIR/.XCompose" ]] && cp "$MODULE_DIR/.XCompose" "$DEST/"

install -Dm755 "$MODULE_DIR/link-dotfiles.sh" /usr/libexec/citadel-dotfiles-link
