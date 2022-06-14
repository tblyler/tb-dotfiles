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
				# Flatpak (could be just about any distro)
				if command -v flatpak &> /dev/null; then
					flatpak update
				fi

				# Debian/Ubuntu
				if command -v apt &> /dev/null; then
					sudo "$SHELL" -c 'apt update && apt upgrade'
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
			nvim --headless -E -c 'PaqSync' -c 'sleep 5' -c 'TSUpdateSync' -c 'sleep 5' -c 'quit'
		fi

		if command -v fwupdmgr &> /dev/null; then
			(
				# 2 is a valid exit code for the fwupdmgr where
				# the operation was successful but did not require
				# action
				set +e

				fwupdmgr refresh
				STATUS=$?
				if [ $STATUS -ne 0 ] && [ $STATUS -ne 2 ]; then
					exit $STATUS
				fi

				fwupdmgr upgrade
				STATUS=$?
				if [ $STATUS -ne 0 ] && [ $STATUS -ne 2 ]; then
					exit $STATUS
				fi
			)
		fi
	)
}
