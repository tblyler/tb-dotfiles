if [ -r ~/.asdf/asdf.sh ]; then
	. ~/.asdf/asdf.sh
	# append completions to fpath
	fpath=(${ASDF_DIR}/completions $fpath)
fi
