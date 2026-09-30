#!/usr/bin/env bash
set -euo pipefail

npm install -g \
	bash-language-server \
	@vtsls/language-server \
	@tailwindcss/language-server \
	@biomejs/biome \
	@mermaid-js/mermaid-cli

GOBIN=/usr/local/bin go install golang.org/x/tools/gopls@latest
GOBIN=/usr/local/bin go install mvdan.cc/gofumpt@latest
GOBIN=/usr/local/bin go install github.com/mgechev/revive@latest
GOBIN=/usr/local/bin go install golang.org/x/tools/cmd/goimports@latest

cargo install --root /usr/local stylua
cargo install --root /usr/local taplo-cli --locked --features lsp
