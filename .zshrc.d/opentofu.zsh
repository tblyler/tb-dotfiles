#!/usr/bin/zsh
# replaces terraform.zsh, which only looked for a system /usr/bin/terraform —
# opentofu (mise.toml [tools]) is what's actually installed
if command -v tofu &> /dev/null; then
	complete -o nospace -C "$(command -v tofu)" tofu
fi
