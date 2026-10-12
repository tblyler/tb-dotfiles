# these used to be zsh functions; they're global mise tasks now (see the
# [tasks] section of mise.toml) so they also work from scripts, ssh and
# systemd. the old names stay as aliases for muscle memory
alias upgrade_system='mise run upgrade'
alias upgrade_dotfiles='mise run dotfiles:upgrade'
alias relink_mise_lockfile='mise run lock:relink'

# a nudge, not a check — this only reads the mtime `mise run dotfiles:upgrade`
# left on FETCH_HEAD the last time it pulled. zsh builtins only: no forks, no network,
# no prompt, so it costs nothing at startup
() {
	emulate -L zsh

	local -i STALE_AFTER_DAYS=5
	local -a FETCH_STAT
	local -i DAYS
	local AGE

	if zstat -A FETCH_STAT +mtime "${HOME}/.dotfiles/.git/FETCH_HEAD" 2> /dev/null; then
		DAYS=$(( (EPOCHSECONDS - FETCH_STAT[1]) / 86400 ))

		if (( DAYS < STALE_AFTER_DAYS )); then
			return
		fi

		AGE="last checked ${DAYS} days ago"
	else
		# no FETCH_HEAD at all — fresh clone that's never been pulled
		AGE="never been checked on this machine"
	fi

	print -P "%F{${PROMPT_COLOR_YELLOW:-yellow}}dotfiles ${AGE}%f — %F{${PROMPT_COLOR_GREEN:-green}}upgrade_dotfiles%f when you get a sec ✨"
}
