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
			asdf update || true
			asdf plugin update --all
			asdf plugin list | awk -v TOOL_VERSIONS_FILE="${HOME}/.tool-versions" '{
				plugins[$0] = 1
			} END {
				while ((getline < TOOL_VERSIONS_FILE) > 0) {
					if (!plugins[$0]) {
						print $0
					}
				}
			}' | xargs -n 1 asdf plugin add
			asdf install

			echo -e 'package\tversion\tlatest\tstatus'
			awk '{
				package = $1
				if(package == "nodejs") {
					next
				}

				installed_version = $2
				("asdf latest " package) | getline
				latest_version = $0
				printf package"\t"installed_version"\t"latest_version"\t"
				if(installed_version == latest_version) {
					print "up-to-date"
				} else {
					print "out-of-date"
				}
			}' "${HOME}/.tool-versions"
			if grep -q '^nodejs' "${HOME}/.tool-versions"; then
				asdf list all nodejs |
					awk -v lts="$(asdf nodejs resolve lts)" \
						-v current="$(asdf current nodejs | awk '{print $2}')" \
						'index($0, lts) == 1 {latest=$0} END {
							printf "nodejs\t"current"\t"latest"\t"
							if(latest == current) {
								print "up-to-date"
							} else {
								print "out-of-date"
							}
						}'
			fi
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
