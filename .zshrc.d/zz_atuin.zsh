# zz_ prefix ensures this loads after fzf, which also binds ^R and would overwrite atuin's binding
if command -v atuin &>/dev/null; then
	eval "$(atuin init zsh)"
fi
