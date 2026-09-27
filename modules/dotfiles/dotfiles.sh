#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="${USER_HOME:-/home/henrique}"

link_dotfiles_dir() {
	local src_dir="$1"

	[[ -d "$src_dir" ]] || return 0

	shopt -s dotglob nullglob
	for entry in "$src_dir"/*; do
		local dest="$USER_HOME/${entry#"$MODULE_DIR"/}"

		mkdir -p "$(dirname "$dest")"
		rm -rf "$dest"
		ln -s "$entry" "$dest"
	done
	shopt -u dotglob nullglob
}

link_dotfiles_dir "$MODULE_DIR/.config"
link_dotfiles_dir "$MODULE_DIR/.local"
