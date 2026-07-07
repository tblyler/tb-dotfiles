if command -v go &> /dev/null; then
	go_coverage() {
		(
			set -eo pipefail
			local -r COVERAGE_OUT="$(mktemp)"
			go test -cover -coverprofile="${COVERAGE_OUT}" ./...
			go tool cover -func="${COVERAGE_OUT}"
			rm -f "${COVERAGE_OUT}"
		)
	}
fi
