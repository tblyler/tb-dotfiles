if command -v aws_completer &> /dev/null; then
	complete -C "$(command -v aws_completer)" aws
fi

_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/aws_profile_set"
mkdir -p "${_CACHE_DIR}"

_PREVIOUS_AWS_PROFILE_FILE="${_CACHE_DIR}/last_set_value"

aws_profile_set() {
	local AWS_CONFIG_PATH="${HOME}/.aws/config"
	if ! [ -r "${AWS_CONFIG_PATH}" ]; then
		>&2 echo "${AWS_CONFIG_PATH} does not exist"
		return 1
	fi

	local PROFILE=""

	PROFILE="$(awk '/^\[profile /{print substr($2, 1, length($2)-1)}' \
		"${AWS_CONFIG_PATH}" |
		fzf --query "${1:-}" -1 -m 1 --height="$((LINES/4))"
	)"

	if [ -z "${PROFILE}" ]; then
		>&2 echo "failed to select a profile"
		return 2
	fi

	echo "setting AWS profile to ${PROFILE}"

	echo "$PROFILE" > "$_PREVIOUS_AWS_PROFILE_FILE"
	export AWS_PROFILE="$PROFILE"

	export _ORIG_PS1="${_ORIG_PS1:-$PS1}"

	export PS1="🌩 ${AWS_PROFILE}🌩  ${_ORIG_PS1}"
}

if [ -s "$_PREVIOUS_AWS_PROFILE_FILE" ]; then
	aws_profile_set "$(<"$_PREVIOUS_AWS_PROFILE_FILE")" < /dev/null &> /dev/null
fi
