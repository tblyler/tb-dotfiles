# create splits in a tmux session for each ssh host
sshtmux() {
	if [ -z "${TMUX}" ]; then
		echo "This must be executed inside of a tmux session"
		return 1
	fi

	if [ -z "${1}" ]; then
		echo "Please provide of list of hosts separated by spaces"
		return 1
	fi

	tmux new-window "ssh"
	for i in ${@}; do
		tmux split-window -h "ssh -o StrictHostKeyChecking=no $i"
		tmux select-layout tiled > /dev/null
		sleep .1s
	done

	tmux select-pane -t 0
}
