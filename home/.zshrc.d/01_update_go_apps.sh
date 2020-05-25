#!/bin/bash
# updates go binary installs that you care about.

# if the GOAPPS environment variable is set, it is expected to be
# an array
update_go_apps() {
	(
		cd || exit $?

		local APPS=("${@}")

		if [ -z "${APPS[0]}" ]; then
			if [ -z "${GOAPPS}" ]; then
				exit 0
			fi

			APPS=("${GOAPPS[@]}")
		fi

		local APP
		for APP in "${APPS[@]}"; do
			echo "Updating ${APP}"
			go get -u "${APP}" || exit $?
		done
	) || return $?
}
