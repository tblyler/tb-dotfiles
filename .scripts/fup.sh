# fup uploads a given file to file.io
fup() {
	if [ -z "${1}" -o ! -f "${1}" ]; then
		echo 'provide a valid file path'
		return 1
	fi

	local cmd="-F 'file=@${1}' https://file.io/"

	if [ ! -z "${2}" ]; then
		cmd="${cmd}\?expires=${2}"
	fi

	local json_return="$(eval "curl ${cmd}")"
	if [ $? -ne 0 ]; then
		echo 'Curl failed'
		return 1
	fi

	if [ $(echo "${json_return}" | grep -c '"success":false') -ne 0 ]; then
		echo "${json_return}"
		return 1
	fi

	echo "https://file.io/$(echo "${json_return}" | sed 's/.*key":"//' | sed 's/".*//')"

	if [ $(echo "${json_return}" | grep -c '"expiry":') -eq 0 ]; then
		echo 'Expires in 14 days'
	else
		echo "Expires in $(echo "${json_return}" | sed 's/.*expiry":"//' | sed 's/".*//')"
	fi

	return 0
}
