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
