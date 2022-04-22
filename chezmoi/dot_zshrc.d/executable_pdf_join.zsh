if [[ "$OSTYPE" = darwin* ]]; then
	pdf_join() {
		(
			set -euo pipefail

			read -r "output_file?Name of output file: "
			"/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" \
				-o "$output_file" "$@"

			open "$output_file"
		)
	}
fi
