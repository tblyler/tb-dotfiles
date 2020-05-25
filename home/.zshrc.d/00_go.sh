#!/bin/bash
if command -v go &> /dev/null; then
	GOPATH="$(go env GOPATH)"
	if [ -n "${GOPATH}" ]; then
		export GOPATH
		export PATH="${GOPATH}/bin:${PATH}"
	fi
else
	>&2 echo '"go" is missing from the PATH'
fi
