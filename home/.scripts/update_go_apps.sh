# updates go binary installs that you care about.

# if the GOAPPS environment variable is set, it is expected to be
# an array
update_go_apps() {
	local APPS=($@)

	if [ -z "${APPS}" ]; then
		if [ -z "${GOAPPS}" ]; then
			return
		fi

		APPS=(${GOAPPS[@]})
	fi

	for APP in "${APPS[@]}"; do
		echo "Updating ${APP}"
		go get -u "${APP}"
	done
}
