if command -v aws_completer &> /dev/null; then
	complete -C "$(command -v aws_completer)" aws
fi

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

	export AWS_PROFILE="$PROFILE"

	export _ORIG_PS1="${_ORIG_PS1:-$PS1}"

	export PS1="🌩 ${AWS_PROFILE}🌩  ${_ORIG_PS1}"
}
