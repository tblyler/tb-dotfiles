if [ -r ~/.asdf/asdf.sh ]; then
	. ~/.asdf/asdf.sh
fi

if command -v brew &> /dev/null && [ -r "$(brew --prefix)/opt/asdf/libexec/asdf.sh" ]; then
	. "$(brew --prefix)/opt/asdf/libexec/asdf.sh"
fi

if [ -n "$ASDF_DIR" ]; then
	# append completions to fpath
	fpath=(${ASDF_DIR}/completions $fpath)
fi
