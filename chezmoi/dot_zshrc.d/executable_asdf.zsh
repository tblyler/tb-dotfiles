if [ -n "$ASDF_DIR" ]; then
	# append completions to fpath
	fpath=(${ASDF_DIR}/completions $fpath)
fi
