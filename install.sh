#!/bin/bash
check_required_cmds() {
	local -r REQUIRED_CMDS=(
		'curl'
		'git'
		'sha256sum'
		'tar'
		'tmux'
		'vim'
		'zsh'
	)

	local RETURN=0
	local REQUIRED_CMD
	for REQUIRED_CMD in ${REQUIRED_CMDS[*]}; do
		if ! command -v "${REQUIRED_CMD}" &> /dev/null; then
			>&2 echo "Missing '${REQUIRED_CMD}' from PATH"
			RETURN=1
		fi
	done

	return "${RETURN}"
}

install_homeshick() {
	local -r HOMESHICK_DIR="${HOME}/.homesick/repos/homeshick"
	if [ -d "${HOMESHICK_DIR}" ]; then
		echo 'homeshick is already installed'
		return
	fi

	git clone https://github.com/andsens/homeshick.git "${HOMESHICK_DIR}"
}

install_ohmyzsh() {
	if [ -d "${HOME}/.oh-my-zsh" ]; then
		echo 'oh-my-zsh is already installed'
		return
	fi

	/bin/bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

install_tpm() {
	local -r TPM="${HOME}/.tmux/plugins/tpm"
	if [ -d "${TPM}" ]; then
		echo 'tpm is already installed'
		return
	fi

	git clone https://github.com/tmux-plugins/tpm "${TPM}"
}

install_go() {
	local -r GO_VERSION='1.13.5'
	local -r GO_SHA256='512103d7ad296467814a6e3f635631bd35574cab3369a97a323c9a585ccaa569'
	source "./home/.zshrc.d/00_go.sh"

	if command -v go &> /dev/null; then
		echo 'go is already installed'
		return
	fi

	echo 'Installing Go 1.13.5, ensure that this is the version you want'
	local -r GO_TAR_FILE="$(mktemp)"
	if ! [ -f "${GO_TAR_FILE}" ]; then
		>&2 echo 'failed to create a file for the go tar'
		return 1
	fi

	if ! curl -L "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" |
		tee "${GO_TAR_FILE}" |
		sha256sum |
		grep -Fq "${GO_SHA256}"; then

		>&2 echo 'failed to download go tar'
		return 2
	fi

	mkdir -p "${GOROOT}" || return $?

	(
		cd "${GOROOT}" || exit $?
		tar -xzf "${GO_TAR_FILE}" || exit $?
		mv go/* ./ || exit $?
		rmdir go || exit $?
	) || return $?

	rm "${GO_TAR_FILE}" || true
}

check_required_cmds || exit $?

echo 'installing homeshick'
install_homeshick
echo 'installing go'
install_go || exit $?
echo 'installing tpm'
install_tpm || exit $?
echo 'installing oh-my-zsh'
install_ohmyzsh || exit $?

echo 'now in zsh, run "upgrade_system"'
