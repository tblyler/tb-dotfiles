#!/bin/bash
# fup uploads a given file to file.io
fup() {
	local -r FILE_PATH="${1}"
	local -r EXPIRATION="${2}"
	if ! [ -f "${FILE_PATH}" ]; then
		echo 'provide a valid file path'
		return 1
	fi

	local URL='https://file.io/'

	if [ -n "${EXPIRATION}" ]; then
		URL="${URL}?expires=${EXPIRATION}"
	fi

	local JSON_RETURN
	if ! JSON_RETURN="$(curl -SsfLF "file=@${FILE_PATH}" "${URL}")"; then
		echo 'Curl failed'
		return 1
	fi

	if echo "${JSON_RETURN}" | grep -q '"success":false'; then
		echo "${JSON_RETURN}"
		return 2
	fi

	echo "https://file.io/$(echo "${JSON_RETURN}" | sed 's/.*key":"//' | sed 's/".*//')"

	if echo "${JSON_RETURN}" | grep -q '"expiry":'; then
		echo "Expires in $(echo "${JSON_RETURN}" | sed 's/.*expiry":"//' | sed 's/".*//')"
	else
		echo 'Expires in 14 days'
	fi

	return 0
}
