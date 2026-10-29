#!/bin/sh
# Claude Code hook: mirrors this session's state into an @agent tmux option on
# its pane and window, which .tmux.conf turns into a status line badge and the
# prefix+a agent picker. on blocked and done, it also asks Claude Code to send a
# desktop notification (OSC 777) via the hook's terminalSequence output: Claude
# Code's own notifications skip a finished response entirely, and only mention a
# permission prompt after ~6s without typing while you seem to be away. Claude
# Code writes that sequence itself, so it gets through tmux (allow-passthrough)
# and works outside tmux too. a system sound plays alongside it, from this
# machine, so only when it isn't over SSH (the terminal bell would carry over
# SSH, but zsh's BEEP option would make it ring on every failed completion too).
#
# like herdr, nothing pings you about a pane you're already looking at: done is
# silent then, and blocked still plays its sound (something is waiting on you)
# but skips the notification. set TMUX_AGENT_SOUND=0 to mute the sounds.
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

case "${1:-}" in
	blocked) message='needs you in' ;;
	done) message='done in' ;;
	*) message= ;;
esac

# herdr already sends its own system notifications and sounds for
# blocked/finished agents
[ -n "$message" ] && [ "${HERDR_ENV:-}" != 1 ] || exit 0

# true when this pane is on screen in a tmux client whose terminal has focus
# (tmux learns that from the terminal via focus-events). outside tmux there's
# no telling, so it's treated as not watched and you always get pinged
pane_watched() {
	[ -n "${TMUX_PANE:-}" ] || return 1

	# a pane hidden behind another pane's zoom isn't on screen
	window=$(tmux display -p -t "$TMUX_PANE" \
		'#{?#{&&:#{window_zoomed_flag},#{!=:#{pane_active},1}},,#{window_id}}' 2> /dev/null)
	[ -n "$window" ] || return 1

	# each client's current window, and whether its terminal has focus
	tmux list-clients -F '#{window_id} #{client_flags}' 2> /dev/null |
		grep -q "^$window .*focused"
}

# plays the first of the given sound files that exists, in the background so
# the hook doesn't wait on it. like herdr, each player is tried in turn until one
# actually succeeds, not just until one is installed (e.g. paplay with no pulse
# server). afplay only exists on macOS, and the macOS sounds only exist there
play_sound() {
	for sound in "$@"; do
		[ -r "$sound" ] || continue
		(
			for player in afplay pw-play paplay 'ffplay -nodisp -autoexit -loglevel quiet' 'mpv --no-video --really-quiet'; do
				# shellcheck disable=SC2086 # player is a command plus its args
				command -v ${player%% *} > /dev/null 2>&1 && $player "$sound" && exit 0
			done
		) < /dev/null > /dev/null 2>&1 &
		return 0
	done
}

watched=false
pane_watched && watched=true

if [ "$watched" = false ] && command -v jq > /dev/null 2>&1; then
	seq=$(printf '\033]777;notify;Claude Code;%s %s\a' "$message" "${where:-${PWD##*/}}")
	jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
fi

if [ -z "${SSH_CONNECTION:-}" ] && [ "${TMUX_AGENT_SOUND:-1}" != 0 ]; then
	# macOS system sounds, then KDE's ocean theme, then the freedesktop theme
	case "$1" in
		blocked) play_sound /System/Library/Sounds/Ping.aiff \
			/usr/share/sounds/ocean/stereo/dialog-question.oga \
			/usr/share/sounds/freedesktop/stereo/dialog-warning.oga ;;
		done) [ "$watched" = true ] || play_sound /System/Library/Sounds/Glass.aiff \
			/usr/share/sounds/ocean/stereo/completion-success.oga \
			/usr/share/sounds/freedesktop/stereo/complete.oga ;;
	esac
fi

# never let a tmux hiccup surface as a hook failure in Claude Code
exit 0
