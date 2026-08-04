# pull the dotfiles repo and apply anything that's out of date on this machine
# explicitly invoked (also called by `upgrade_system`) — nothing happens at
# shell startup
upgrade_dotfiles() {
	(
		set -euo pipefail

		readonly DOTFILES_DIR="$HOME/.dotfiles"

		echo 'Checking if dotfiles have updates...'
		git -C "$DOTFILES_DIR" pull --rebase --quiet

		if [ -z "$(mise bootstrap -C "$DOTFILES_DIR" status --missing)" ]; then
			echo 'nope! Good bye!'
			# there is nothing different between the dotfiles repo and what is
			# applied to this machine
			exit 0
		fi

		mise bootstrap -C "$DOTFILES_DIR" --dry-run

		while true; do
			read -r 'APPLY?apply? [y/N] '

			case "$APPLY" in
				'y'|'Y'|'YES'|'yes'|'Yes')
					echo 'applying changes'
					mise bootstrap -C "$DOTFILES_DIR" --yes
					exit 0
					;;

				'n'|'N'|'NO'|'no'|'No'|'')
					echo 'not applying changes'
					exit 0
					;;
			esac
		done
	)
}

# a nudge, not a check — this only reads the mtime `upgrade_dotfiles` left on
# FETCH_HEAD the last time it pulled. zsh builtins only: no forks, no network,
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
