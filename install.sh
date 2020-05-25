#!/bin/bash
readonly HOMESHICK_DIR="${HOME}/.homesick/repos/homeshick"

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

install_custom_ohmyzsh_plugins() {
	local REPOS=(
		https://github.com/zsh-users/zsh-autosuggestions
		https://github.com/zsh-users/zsh-syntax-highlighting
	)

	local REPO
	local ZSH_CUSTOM_DEST
	for REPO in ${REPOS[*]}; do
		ZSH_CUSTOM_DEST="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/$(basename "${REPO}")"

		if [ -d "${ZSH_CUSTOM_DEST}" ]; then
			continue
		fi

		git clone \
			"${REPO}" \
			"${ZSH_CUSTOM_DEST}" || exit $?
	done
}

install_tmux_conf() {
	if [ -d "${HOME}/.tmux" ]; then
		echo '.tmux already exists'
		return
	fi

	(
		set -e
		cd
		git clone https://github.com/gpakosz/.tmux.git
		ln -s .tmux/.tmux.conf ./
	)
}

check_required_cmds || exit $?

echo 'installing homeshick'
install_homeshick || exit $?
echo 'installing oh-my-zsh'
install_ohmyzsh || exit $?
echo 'installing custom ohmyzsh plugins'
install_custom_ohmyzsh_plugins || exit $?
echo 'installing tmux config'
install_tmux_conf || exit $?

source "${HOMESHICK_DIR}/homeshick.sh"

homeshick clone https://github.com/tblyler/tb-dotfiles

echo 'now in zsh, run "upgrade_system"'
