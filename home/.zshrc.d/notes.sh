#!/bin/bash

notes() {
	local -r NOTES_DIR="${NOTES_DIR:-${HOME}/notes}"

	for ARG in "$@"; do
		(
			set -euo pipefail
			mkdir -p "$NOTES_DIR"
			cd "$NOTES_DIR"

			case "${ARG}" in
				'ls')
					ag -g '' -l "${NOTES_DIR}" | sort -hr
					;;

				'status')
					git status
					;;

				'commit')
					git add .
					git commit -m "notes commit $(date)"
					;;

				'push')
					git push
					;;

				'pull')
					git pull
					;;

				*)
					>&2 echo "invalid argument ${ARG}"
					exit 1
					;;
			esac
		) || return $?
	done

	# return if the above loop didn't return a bad code
	if [ -n "$*" ]; then
		return
	fi

	(
		set -euo pipefail

		readonly NOW="$(date +%s)"

		readonly FILE_PATH="${NOTES_DIR}/$(date -d "@${NOW}" +'%Y/%m/%Y-%m-%d').md"

		mkdir -p "$(dirname "${FILE_PATH}")"
		if ! [ -e "${FILE_PATH}" ]; then
			echo -e "# $(date -d "@${NOW}" +'%a %d %b %Y')\n\n## todo\n\n" > "${FILE_PATH}"
		fi

		"${EDITOR:-vim}" "${FILE_PATH}"
	)
}
