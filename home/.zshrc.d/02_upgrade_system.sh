#!/bin/bash

upgrade_system() {
	case "$(uname | tr '[:upper:]' '[:lower:]')" in
		'darwin')
			if command -v brew &> /dev/null; then
				brew update || return $?
				brew upgrade || return $?
			fi
			;;

		'linux')
			# Debian/Ubuntu
			if command -v apt &> /dev/null; then
				sudo sh -c 'apt update && apt upgrade' || return $?
			fi

			# Fedora
			if command -v dnf &> /dev/null; then
				sudo dnf upgrade || return $?
			fi

			# Arch
			if command -v yay &> /dev/null; then
				yay -Syu || return $?
			elif command -v pacman &> /dev/null; then
				sudo pacman -Syu || return $?
			fi
			;;
	esac

	if command -v update_go_apps &> /dev/null; then
		update_go_apps || return $?
	fi

	if command -v vim &> /dev/null; then
		vim -c 'PlugUpgrade | q' || return $?
		vim -c 'PlugUpdate | sleep 3 | qa' || return $?
	fi

	(
		set -e

		cd "${ZSH}/custom/plugins"

		for FILE in *; do
			if ! [ -d "${FILE}" ]; then
				continue
			fi

			(
				cd "${FILE}"
				[ -d .git ] || exit 0
				git pull
			)
		done
	) || return $?

	(
		set -e

		cd "${HOME}/.tmux"
		git pull
		if [ -n "${TMUX}" ]; then
			tmux source-file "${HOME}/.tmux.conf"
		fi
	)

	if command -v fwupdmgr &> /dev/null; then
		(
			set -e
			fwupdmgr refresh
			fwupdmgr upgrade
		)
	fi
}
