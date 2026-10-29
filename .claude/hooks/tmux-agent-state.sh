#!/bin/sh
# Claude Code hook: mirrors this session's state into an @agent tmux option on
# its pane and window, which .tmux.conf turns into a status line badge and the
# prefix+a agent picker. on done, it also asks Claude Code to send a desktop
# notification (OSC 777) via the hook's terminalSequence output, since Claude
# Code only notifies on its own when it's waiting on you, not when it finishes a
# response. Claude Code writes that sequence itself, so it gets through tmux
# (allow-passthrough) and works outside tmux too.
#
# usage: tmux-agent-state.sh working|blocked|done|off

cat > /dev/null # drain the hook's JSON input

if [ -n "${TMUX_PANE:-}" ] && command -v tmux > /dev/null 2>&1; then
	if [ "${1:-}" = off ]; then
		tmux set -pu -t "$TMUX_PANE" @agent \; set -wu -t "$TMUX_PANE" @agent 2> /dev/null
	else
		tmux set -p -t "$TMUX_PANE" @agent "$1" \; set -w -t "$TMUX_PANE" @agent "$1" 2> /dev/null
	fi
	where=$(tmux display -p -t "$TMUX_PANE" '#S:#W' 2> /dev/null)
fi

# herdr already sends its own system notification when an agent finishes
if [ "${1:-}" = done ] && [ "${HERDR_ENV:-}" != 1 ] && command -v jq > /dev/null 2>&1; then
	seq=$(printf '\033]777;notify;Claude Code;done in %s\a' "${where:-${PWD##*/}}")
	jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
fi

# never let a tmux hiccup surface as a hook failure in Claude Code
exit 0
