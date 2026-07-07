if [ "$EDITOR" = 'nvim' ]; then
	alias vi='nvim'
	alias vim='nvim'
	alias vimdiff="nvim -d"
	alias view="nvim -R"
fi

# use reflink cp if supported (yay CoW)
if 2>&1 cp --help | grep -qF -- --reflink; then
	alias cp='cp -i --reflink=auto'
else
	alias cp='cp -i'
fi

alias mv='mv -i'

if command -v docker-compose &> /dev/null; then
	alias dco='docker-compose'
fi

case "$OSTYPE" in
	darwin*)
		if command -v gtar &> /dev/null; then
			alias tar='gtar'
		fi

		if command -v gsed &> /dev/null; then
			alias sed='gsed'
		fi
		;;

	linux*)
		alias open='xdg-open'
		;;
esac
