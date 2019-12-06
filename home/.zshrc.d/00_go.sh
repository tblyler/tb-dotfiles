#!/bin/bash
export GOROOT="${HOME}/.goroot"
export PATH="${GOROOT}/bin:${PATH}"

if command -v go &> /dev/null; then
	GOPATH="$(go env GOPATH)"
	if [ -n "${GOPATH}" ]; then
		export GOPATH
		export PATH="${GOPATH}/bin:${PATH}"
	fi
else
	>&2 echo '"go" is missing from the PATH, you should run "install.sh"'
fi
