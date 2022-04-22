#!/usr/bin/zsh

if command -v dircolors &> /dev/null; then
	if test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)"; then
		:
	else
		eval "$(dircolors -b)"
	fi

	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi
