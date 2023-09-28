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

		if command -v asdf &> /dev/null; then
			(
				cd "$HOME"
				asdf update || true
				asdf plugin update --all
				asdf latest --all | grep -Ev '^(python|nodejs)'
				LATEST_PYTHON_VERSION="$(asdf latest python)"
				CURRENT_PYTHON_VERSION="$(asdf current python | awk '{print $2}')"
				echo -en "python\t${LATEST_PYTHON_VERSION}\t"
				if [[ "$LATEST_PYTHON_VERSION" == "$CURRENT_PYTHON_VERSION" ]]; then
					echo "installed"
				else
					echo "missing"
				fi
				asdf list all nodejs |
					awk -v lts="$(asdf nodejs resolve lts)" \
					-v current="$(asdf current nodejs | awk '{print $2}')" \
					'index($0, lts) == 1 {latest=$0} END {
						printf "nodejs\t"latest"\t"
						if(latest == current) {
							print "installed"
						} else {
							print "missing"
						}
					}'
			)
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
