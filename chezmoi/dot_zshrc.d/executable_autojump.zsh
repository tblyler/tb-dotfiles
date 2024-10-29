if [ -r /usr/share/autojump/autojump.zsh ]; then
	source /usr/share/autojump/autojump.zsh
elif [ -r /usr/share/autojump/autojump.sh ]; then
	source /usr/share/autojump/autojump.sh
elif [ -r "${HOMEBREW_PREFIX}/share/autojump/autojump.zsh" ]; then
	source "${HOMEBREW_PREFIX}/share/autojump/autojump.zsh"
fi
