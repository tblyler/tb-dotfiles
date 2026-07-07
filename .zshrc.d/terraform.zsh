#!/usr/bin/zsh

if [ -e /usr/bin/terraform ]; then
	complete -o nospace -C /usr/bin/terraform terraform
fi
