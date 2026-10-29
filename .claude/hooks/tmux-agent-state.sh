#!/bin/sh
# Claude Code hook: mirrors this session's state into an @agent tmux option on
# its pane and window, which .tmux.conf turns into a status line badge and the
# prefix+a agent picker. desktop notifications aren't handled here; Claude Code
# sends those itself, through tmux's allow-passthrough.
#
# usage: tmux-agent-state.sh working|blocked|done|off

cat > /dev/null # drain the hook's JSON input

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux > /dev/null 2>&1 || exit 0

if [ "${1:-}" = off ]; then
	tmux set -pu -t "$TMUX_PANE" @agent \; set -wu -t "$TMUX_PANE" @agent 2> /dev/null
else
	tmux set -p -t "$TMUX_PANE" @agent "$1" \; set -w -t "$TMUX_PANE" @agent "$1" 2> /dev/null
fi

# never let a tmux hiccup surface as a hook failure in Claude Code
exit 0
