#!/usr/bin/zsh

(
	set -euo pipefail

	if ! command -v docker &> /dev/null; then
		exit 0
	fi

	zstyle ':completion:*:*:docker:*' option-stacking yes
	zstyle ':completion:*:*:docker-*:*' option-stacking yes

	DOCKER_COMPLETION_FILE="${ZSH_COMPLETIONS_DIR}/_docker"

	if [ -r "$DOCKER_COMPLETION_FILE" ]; then
		zstat -H COMPLETION_FILE_STAT "$DOCKER_COMPLETION_FILE"
		zstat -H DOCKER_FILE_STAT "$(command -v docker)"

		if [ "${COMPLETION_FILE_STAT[ctime]}" -ge "${DOCKER_FILE_STAT[ctime]}" ]; then
			exit 0
		fi
	fi

	curl -LSsf https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker -o "$DOCKER_COMPLETION_FILE"
	chmod +x "$DOCKER_COMPLETION_FILE"
)
