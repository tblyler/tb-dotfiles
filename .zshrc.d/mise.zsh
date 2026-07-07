#!/usr/bin/zsh
# shell activation itself happens in .zprofile/.zshrc directly — [dotfiles]
# owns both whole-file, and [bootstrap.mise_shell_activate] silently refuses
# to inject into files it doesn't fully control, so this only handles
# completion caching
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
