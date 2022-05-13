function jqi() {
	(
		set -euo pipefail
		if [ "${1:--}" = "-" ]; then
			INPUT="$(mktemp)"
			trap 'rm -f "$INPUT"' EXIT
			> "$INPUT"
		else
			INPUT="$1"
		fi

		export INPUT

		echo | fzf --phony \
			--preview-window='up:90%' \
			--print-query \
			--preview 'jq --color-output -r {q} "$INPUT"'
	)
}
