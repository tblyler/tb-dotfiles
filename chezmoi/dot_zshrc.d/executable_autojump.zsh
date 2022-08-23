if [ -r /usr/share/autojump/autojump.sh ]; then
	source /usr/share/autojump/autojump.sh
fi

if [ -r "${HOMEBREW_PREFIX}/share/autojump/autojump.zsh" ]; then
	source "${HOMEBREW_PREFIX}/share/autojump/autojump.zsh"
fi
