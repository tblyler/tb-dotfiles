#!/bin/bash

weather() {
	if ! command -v wego &> /dev/null; then
		return 1
	fi

	local -r LOCK_DATE="/tmp/wego-$(date '+%F-%H')"
	if [ -e "${LOCK_DATE}" ]; then
		return 0
	fi

	touch "${LOCK_DATE}"
	wego
}

weather
