if [ -e "${HOME}/.zshrc.d/cbi.sh" ]; then
	source "${HOME}/.zshrc.d/cbi.sh" 2>/dev/null
fi

if [ "$TTY" = '/dev/tty1' ] && [ -t 0 ] && [ -t 1 ] && [ -t 2 ]; then
	startx
	exit
fi
