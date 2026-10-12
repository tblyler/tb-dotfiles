if command -v go &> /dev/null; then
	# a global mise task now (see mise.toml); the alias keeps the old name
	alias go_coverage='mise run go:coverage'
fi
