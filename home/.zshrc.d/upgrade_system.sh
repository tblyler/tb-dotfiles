#!/bin/bash

upgrade_system() {
	(
		set -euo pipefail

		case "$(uname | tr '[:upper:]' '[:lower:]')" in
			'darwin')
				if command -v brew &> /dev/null; then
					brew update
					brew upgrade
				fi
				;;

			'linux')
				# Debian/Ubuntu
				if command -v apt &> /dev/null; then
					sudo sh -c 'apt update && apt upgrade'
				fi

				# Fedora
				if command -v dnf &> /dev/null; then
					sudo dnf upgrade
				fi

				# Arch
				if command -v yay &> /dev/null; then
					yay -Syu --devel --timeupdate
				elif command -v pacman &> /dev/null; then
					sudo pacman -Syu
				fi
				;;
		esac

		if command -v nvim &> /dev/null; then
			nvim -c 'PaqSync' -c 'sleep 5' -c 'qa'
		fi

		(
			for DIR in "$ZSH"/custom/{themes,plugins}/*/; do
				(
					cd "${DIR}"
					[ -d .git ] || exit 0
					git pull
				)
			done
		)

		(
			cd "${HOME}/.tmux"
			git pull
			if [ -n "${TMUX:-}" ]; then
				tmux source-file "${HOME}/.tmux.conf"
			fi
		)

		if command -v fwupdmgr &> /dev/null; then
			fwupdmgr refresh
			fwupdmgr upgrade
		fi
	)
}
