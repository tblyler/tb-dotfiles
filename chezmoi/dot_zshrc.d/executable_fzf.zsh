2>/dev/null for FZF_FILE in /usr/share/doc/fzf/examples/*.zsh; do
	source "$FZF_FILE"
done

2>/dev/null for FZF_FILE in /usr/share/fzf/shell/*.zsh; do
	source "$FZF_FILE"
done

2>/dev/null for FZF_FILE in /opt/homebrew/opt/fzf/shell/*.zsh; do
	source "$FZF_FILE"
done
