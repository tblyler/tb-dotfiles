#!usr/bin/zsh
if command -v kubectl &> /dev/null; then
	alias k=kubectl
	(
		set -euo pipefail

		readonly KUBECTL_COMPLETION_FILE="${ZSH_COMPLETIONS_DIR}/_kubectl"

		if [ -r "$KUBECTL_COMPLETION_FILE" ]; then
			zstat -H KUBECTL_COMPLETION_FILE_STAT "$KUBECTL_COMPLETION_FILE"
			zstat -H KUBECTL_FILE_STAT "$(command -v kubectl)"

			if [ "${KUBECTL_COMPLETION_FILE_STAT[ctime]}" -ge "${KUBECTL_FILE_STAT[ctime]}" ]; then
				exit 0
			fi
		fi

		kubectl completion zsh > "$KUBECTL_COMPLETION_FILE"
		chmod +x "$KUBECTL_COMPLETION_FILE"
	)
fi
