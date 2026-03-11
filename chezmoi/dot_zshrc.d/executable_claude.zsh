#!/usr/bin/zsh
if command -v claude &> /dev/null; then
	alias askbff='claude --print'
	alias bff='claude'
	alias askc='claude --print'
	alias c='claude'
fi
