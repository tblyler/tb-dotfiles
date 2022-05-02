# completion
(
	set -euo pipefail

	CHEZMOI_PATH="$(command -v chezmoi 2> /dev/null)"

	COMPLETION_FILE="${ZSH_COMPLETIONS_DIR}/_chezmoi"
	if [ -r "$COMPLETION_FILE" ]; then
		COMPLETION_FILE_CTIME="$(stat -c %Z "$COMPLETION_FILE")"
		CHEZMOI_FILE_CTIME="$(stat -c %Z "${CHEZMOI_PATH}")"

		if [ "$COMPLETION_FILE_CTIME" -ge "$CHEZMOI_FILE_CTIME" ]; then
			exit 0
		fi
	fi

	chezmoi completion zsh > "$COMPLETION_FILE"
	chmod +x "$COMPLETION_FILE"
)

# auto update
(
	set -euo pipefail

	# has the chezmoi repo been pulled in the last 24 hours?
	if [ "$(date +%s -r "$(chezmoi git rev-parse -- --show-toplevel)/.git/FETCH_HEAD")" -gt $((EPOCHSECONDS-86400)) ]; then
		exit 0
	fi

	chezmoi git pull -- --rebase
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
