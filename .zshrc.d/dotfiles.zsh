# auto update dotfiles
(
	set -euo pipefail

	readonly DOTFILES_DIR="$HOME/.dotfiles"

	zstat -H LAST_PULL_STAT "${DOTFILES_DIR}/.git/FETCH_HEAD"

	# has the dotfiles repo been pulled in the last 24 hours?
	if [ "${LAST_PULL_STAT[ctime]}" -gt $((EPOCHSECONDS-86400)) ]; then
		exit 0
	fi

	echo 'Checking if dotfiles have updates...'
	git -C "$DOTFILES_DIR" pull --rebase --quiet

	if [ -z "$(mise bootstrap -C "$DOTFILES_DIR" status --missing)" ]; then
		echo 'nope! Good bye!'
		# there is nothing different between the dotfiles repo and what is
		# applied to this machine
		exit 0
	fi

	while true; do
		read -r 'CONTINUE?Dotfiles have updates, review now? [y/N] '

		case "$CONTINUE" in
			'y'|'Y'|'YES'|'yes'|'Yes')
				break
				;;

			'n'|'N'|'NO'|'no'|'No'|'')
				echo 'not applying changes'
				exit 0
				;;
		esac
	done

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
