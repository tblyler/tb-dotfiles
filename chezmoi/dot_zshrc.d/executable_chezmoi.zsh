# completion
(
	set -euo pipefail

	CHEZMOI_PATH="$(command -v chezmoi 2> /dev/null)"

	COMPLETION_FILE="${ZSH_COMPLETIONS_DIR}/_chezmoi"
	if [ -r "$COMPLETION_FILE" ]; then
		zstat -H COMPLETION_FILE_STAT "$COMPLETION_FILE"
		zstat -H CHEZMOI_FILE_STAT "${CHEZMOI_PATH}"

		if [ "${COMPLETION_FILE_STAT[ctime]}" -ge "${CHEZMOI_FILE_STAT[ctime]}" ]; then
			exit 0
		fi
	fi

	chezmoi completion zsh > "$COMPLETION_FILE"
	chmod +x "$COMPLETION_FILE"
)

# auto update
(
	set -euo pipefail

	zstat -H LAST_PULL_STAT "$(chezmoi git rev-parse -- --show-toplevel)/.git/FETCH_HEAD"

	# has the chezmoi repo been pulled in the last 24 hours?
	if [ "${LAST_PULL_STAT[ctime]}" -gt $((EPOCHSECONDS-86400)) ]; then
		exit 0
	fi

	chezmoi git pull -- --rebase
	if [ "$(chezmoi status)" = "" ]; then
		# there is nothing different between chezmoi and what is
		# applied to this machine
		exit 0
	fi

	chezmoi diff

	while true; do
		read -r 'APPLY?apply? [y/N] '

		case "${APPLY:-}" in
			'y'|'Y'|'YES'|'yes'|'Yes')
				echo 'applying changes'
				chezmoi apply
				exit 0
				;;

			'n'|'N'|'NO'|'no'|'No'|'')
				echo 'not applying changes'
				exit 0
				;;
		esac
	done
)
