# auto install oh-my-zsh and tpm
if which git > /dev/null 2>&1; then
	# if oh-my-zsh is not installed, autoinstall it
	if [ ! -e "${ZSH}" ]; then
		echo 'oh-my-zsh is missing... autoinstalling now'
		sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	fi

	local TPM="${HOME}/.tmux/plugins/tpm"
	# if tpm (Tmux Plugin Manager) is not installed, autoinstall it
	if [ ! -e "${TPM}" ]; then
		git clone https://github.com/tmux-plugins/tpm "${TPM}"
	fi

	if ! egrep -q 'run.*tpm' "${HOME}/.tmux.conf" 2>&1; then
		echo 'adding TPM to ~/.tmux.conf'
		echo "run '${HOME}/.tmux/plugins/tpm/tpm'" >> "${HOME}/.tmux.conf"
	fi
fi
