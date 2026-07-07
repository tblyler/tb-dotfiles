if command -v zoxide &> /dev/null; then
	eval "$(zoxide init zsh)"
	alias j=z
	alias ji=zi
fi
