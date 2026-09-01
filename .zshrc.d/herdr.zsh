#!/usr/bin/zsh
if command -v herdr &> /dev/null; then
	alias h='herdr'

	(
		set -euo pipefail
		readonly HERDR_COMPLETION_FILE="${ZSH_COMPLETIONS_DIR}/_herdr"

		if [ -r "$HERDR_COMPLETION_FILE" ]; then
			zstat -H COMPLETION_FILE_STAT "$HERDR_COMPLETION_FILE"
			zstat -H HERDR_FILE_STAT "$(whence -p herdr)"

			if [ "${COMPLETION_FILE_STAT[ctime]}" -ge "${HERDR_FILE_STAT[ctime]}" ]; then
				exit 0
			fi
		fi

		herdr completion zsh > "$HERDR_COMPLETION_FILE"
		chmod +x "$HERDR_COMPLETION_FILE"
	)
fi
