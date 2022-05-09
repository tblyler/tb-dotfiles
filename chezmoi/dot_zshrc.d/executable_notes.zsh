#!/bin/bash

notes() {
	local NOTES_DIR="${NOTES_DIR:-${HOME}/notes}"
	local -r EDITOR="${EDITOR:-vim}"
	local EDITOR_OPTIONS=()

	if [[ "${EDITOR}" =~ 'vim$' ]]; then
		EDITOR_OPTIONS=(
			'-c'
			'set spell'
		)
	fi


	for ARG in "$@"; do
		(
			set -euo pipefail
			mkdir -p "$NOTES_DIR"
			cd "$NOTES_DIR"

			case "${ARG}" in
				'category')
					shift
					export NOTES_DIR="$NOTES_DIR/$1"
					shift

					notes "$@"
					exit 255
					;;

				'fzf')
					"${EDITOR}" "${EDITOR_OPTIONS[@]}" "$(notes ls | fzf)"
					;;

				'ls')
					ag -g '' -l "${NOTES_DIR}" | sort -hr
					;;

				'status')
					git status
					;;

				'commit')
					git add .
					git commit -m "notes commit $(strftime '%a %d %b %Y %r %Z')"
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
		)

		local EXIT_CODE=$?
		if [ $EXIT_CODE != 0 ]; then
			if [ $EXIT_CODE = 255 ]; then
				return 0
			fi

			return $EXIT_CODE
		fi
	done

	# return if the above loop didn't return a bad code
	if [ -n "$*" ]; then
		return
	fi

	(
		set -euo pipefail

		readonly NOW="$EPOCHSECONDS"
		readonly FILE_PATH="${NOTES_DIR}/$(strftime '%Y/%m/%Y-%m-%d.md' "$NOW")"

		mkdir -p "$(dirname "${FILE_PATH}")"
		if ! [ -e "${FILE_PATH}" ]; then
			echo -e "# $(strftime '%a %d %b %Y' "$NOW")\n\n## todo\n\n" > "${FILE_PATH}"
		fi

		"${EDITOR}" "${EDITOR_OPTIONS[@]}" "${FILE_PATH}"
	)
}
