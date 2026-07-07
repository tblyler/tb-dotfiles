#!/usr/bin/zsh
# shell activation itself is handled by [bootstrap.mise_shell_activate] in mise.toml
if command -v mise &> /dev/null; then
	(
		set -euo pipefail
		readonly MISE_COMPLETION_FILE="${ZSH_COMPLETIONS_DIR}/_mise"

		if [ -r "$MISE_COMPLETION_FILE" ]; then
			zstat -H COMPLETION_FILE_STAT "$MISE_COMPLETION_FILE"
			zstat -H MISE_FILE_STAT "$(whence -p mise)"

			if [ "${COMPLETION_FILE_STAT[ctime]}" -ge "${MISE_FILE_STAT[ctime]}" ]; then
				exit 0
			fi
		fi

		mise completion zsh > "$MISE_COMPLETION_FILE"
		chmod +x "$MISE_COMPLETION_FILE"
	)
fi
