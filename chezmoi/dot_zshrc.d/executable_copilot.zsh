#!/usr/bin/zsh

(
	set -euo pipefail

	if ! command -v copilot &> /dev/null; then
		exit 0
	fi

	COPILOT_COMPLETION_PATH="${ZSH_COMPLETIONS_DIR}/_copilot"

	if [ -r "$COPILOT_COMPLETION_PATH" ]; then
		zstat -H COMPLETION_FILE_STAT "$COPILOT_COMPLETION_PATH"
		zstat -H COPILOT_FILE_STAT "$(command -v copilot)"

		if [ "${COMPLETION_FILE_STAT[ctime]}" -ge "${COPILOT_FILE_STAT[ctime]}" ]; then
			exit 0
		fi
	fi

	copilot completion zsh > "$COPILOT_COMPLETION_PATH"
	chmod +x "$COPILOT_COMPLETION_PATH"
)
