#!/usr/bin/env bash
# Roda em runtime (systemd --user, no login) — aqui $HOME já existe de
# verdade (/home resolve pra /var/home), diferente de quando dotfiles.sh
# rodou em build-time. Idempotente: só recria o link se ele mudou.
set -euo pipefail

SRC="/usr/share/citadel-dotfiles"

link_entry() {
	local target="$1" dest="$2"

	mkdir -p "$(dirname "$dest")"
	if [[ -L "$dest" && "$(readlink "$dest")" == "$target" ]]; then
		return 0
	fi
	rm -rf "$dest"
	ln -s "$target" "$dest"
}

link_dir() {
	local src_dir="$1"
	[[ -d "$src_dir" ]] || return 0

	shopt -s dotglob nullglob
	for entry in "$src_dir"/*; do
		link_entry "$entry" "$HOME/${entry#"$SRC"/}"
	done
	shopt -u dotglob nullglob
}

link_dir "$SRC/.config"
link_dir "$SRC/.local"

[[ -f "$SRC/.XCompose" ]] && link_entry "$SRC/.XCompose" "$HOME/.XCompose"
