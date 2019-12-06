#!/bin/bash

upgrade_system() {
	if command -v apt &> /dev/null; then
		sudo sh -c 'apt update && apt upgrade' || return $?
	fi

	if command -v dnf &> /dev/null; then
		sudo dnf upgrade || return $?
	fi

	if command -v update_go_apps &> /dev/null; then
		update_go_apps || return $?
	fi

	if command -v vim &> /dev/null; then
		vim -c 'PlugUpgrade | q' || return $?
		vim -c 'PlugUpdate | sleep 3 | qa' || return $?
	fi

	(
		cd "${HOME}/.tmux/plugins/tpm" || exit 0
		if [ -x ./clean_plugins ]; then
			./clean_plugins || exit $?
		fi

		if [ -x ./install_plugins ]; then
			./install_plugins || exit $?
		fi

		if [ -x ./update_plugins ]; then
			./update_plugins all || exit $?
		fi
	) || return $?
}
