note() {
	local DATE="$(date '+%s')"
	local BASE_NOTE_PATH="${NOTE_PATH:-$(pwd)}"
	local IS_DATE_PATH=1
	if [[ "${1}" =~ '^ *[-+]{0,1}[0-9]+ *$' ]]; then
		local DAY=86400
		local DATE=$(( DATE + (DAY * ${1}) ))

	elif [[ -n "${1}" ]]; then
		local IS_DATE_PATH=''
		local NOTE_PATH="${BASE_NOTE_PATH}/${1}"
		if ! [[ "${1}" =~ '\.[mM][dD]$' ]]; then
			local NOTE_PATH="${NOTE_PATH}.md"
		fi
	fi

	if [[ ${IS_DATE_PATH} ]]; then
		local NOTE_PATH="${BASE_NOTE_PATH}/$(date --date "@${DATE}" '+%Y/%m')"
		mkdir -p "${NOTE_PATH}" || return 1
		local NOTE_PATH="${NOTE_PATH}/$(date --date "@${DATE}" '+%d').md"
	else
		mkdir -p "$(dirname "${NOTE_PATH}")" || return 2
	fi

	vim "${NOTE_PATH}" || return 3
}
