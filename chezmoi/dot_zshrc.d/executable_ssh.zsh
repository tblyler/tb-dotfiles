SSH_ENV_CACHE="$HOME/.ssh/environment-$HOST"

function _start_agent() {
	if _check_ssh_agent_connectivity; then
		return
	fi

	if [[ -r "$SSH_ENV_CACHE" ]]; then
		. $SSH_ENV_CACHE &> /dev/null
		if _check_ssh_agent_connectivity; then
			return
		fi
	fi

	echo -n >! "$SSH_ENV_CACHE"
	chmod 600 "$SSH_ENV_CACHE"
	ssh-agent -s > "$SSH_ENV_CACHE"
	. "$SSH_ENV_CACHE" > /dev/null
}

function _check_ssh_agent_connectivity() {
	ssh-add -l &> /dev/null
	if [[ $? -eq 2 ]]; then
		return 1
	fi
}

function add_ssh_keys() {
	declare -a NEW_IDENTITIES

	SSH_AGENT_IDENTITIES="$(ssh-add -l || true)"
	2>/dev/null for IDENTITY_FILE in ~/.ssh/id_*~*.pub; do
		if [[ "$SSH_AGENT_IDENTITIES" != *"$(ssh-keygen -lf "$IDENTITY_FILE")"* ]]; then
			NEW_IDENTITIES+=("$IDENTITY_FILE")
		fi
	done

	if [[ ${#NEW_IDENTITIES} -gt 0 ]]; then
		ssh-add ${^NEW_IDENTITIES}
	fi
}

_start_agent && add_ssh_keys
