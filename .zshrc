#!/usr/bin/zsh

eval "$(mise activate zsh)"

zmodload zsh/datetime
# load the stat module but only with the `zstat` command
# leave `stat` to the system's stat command
zmodload -F zsh/stat b:zstat

autoload -Uz \
	colors \
	compinit \
	select-word-style \
	vcs_info \
	zcalc

# make control w remove by word better
select-word-style bash

colors

autoload -Uz bashcompinit

setopt \
	ALWAYS_TO_END \
	AUTO_CD \
	AUTO_PUSHD \
	BEEP \
	COMPLETE_IN_WORD \
	EXTENDED_GLOB \
	EXTENDED_HISTORY \
	HIST_IGNORE_DUPS \
	HIST_IGNORE_SPACE \
	HIST_REDUCE_BLANKS \
	HIST_VERIFY \
	INTERACTIVE_COMMENTS \
	LONG_LIST_JOBS \
	NOTIFY \
	NULL_GLOB \
	PROMPT_SUBST \
	PUSHD_IGNORE_DUPS \
	PUSHD_MINUS \
	SHARE_HISTORY

# fallback prompt colors, overridden below if the private dracula-pro repo
# is available (see ~/repos/dracula-pro/themes/zsh)
PROMPT_COLOR_RED='red'
PROMPT_COLOR_WHITE='white'
PROMPT_COLOR_GREY='white'
PROMPT_COLOR_YELLOW='yellow'
PROMPT_COLOR_GREEN='green'
PROMPT_COLOR_BLUE='blue'
PROMPT_COLOR_ORANGE='yellow'
PROMPT_COLOR_CYAN='cyan'
PROMPT_COLOR_PINK='magenta'
[ -r "${HOME}/repos/dracula-pro/themes/zsh/van-helsing.zsh" ] && source "${HOME}/repos/dracula-pro/themes/zsh/van-helsing.zsh"

NEWLINE=$'\n'
PS_SEPARATOR="%F{$PROMPT_COLOR_GREY} > %f"

function precmd() {
	vcs_info
}

VCS_ROOT_DIR=''
function +vi-git-vcs-set-message-hook() {
	VCS_ROOT_DIR="${hook_com[base]}"

	if [ -z "$VCS_ROOT_DIR" ]; then
		return
	fi

	if [[ "${VCS_ROOT_DIR:0:${#HOME}}" = "${HOME}" ]]; then
		VCS_ROOT_DIR="~${VCS_ROOT_DIR:${#HOME}}"
	fi

	hook_com[misc]="$(2> /dev/null git status --short | awk \
		-v cAdd="$PROMPT_COLOR_GREEN" \
		-v cChange="$PROMPT_COLOR_ORANGE" \
		-v cDel="$PROMPT_COLOR_RED" \
		-v cStruct="$PROMPT_COLOR_CYAN" \
		-v cConflict="$PROMPT_COLOR_RED" \
		-v cUntracked="$PROMPT_COLOR_PINK" \
		-v cDefault="$PROMPT_COLOR_WHITE" \
		'
		function color_for(code) {
			if (code == "DD" || code == "AU" || code == "UD" || code == "UA" || code == "DU" || code == "AA" || code == "UU") return cConflict;
			c = substr(code, 1, 1);
			if (c == "A") return cAdd;
			if (c == "M" || c == "T") return cChange;
			if (c == "D") return cDel;
			if (c == "R" || c == "C") return cStruct;
			if (c == "U") return cConflict;
			if (c == "?") return cUntracked;
			return cDefault;
		}
		{counts[$1]++}
		END {
			printed = "";
			for (count_type in counts) {
				letter = substr(count_type, 1, 1);
				printf "%s%%F{%s}%%B%s%%b%d%%f", printed, color_for(count_type), letter, counts[count_type];
				printed = " ";
			}
		}')"
}

zstyle ':vcs_info:git*' formats "%F{$PROMPT_COLOR_GREEN}%b%f %m${PS_SEPARATOR}"
zstyle ':vcs_info:git*' actionformats "%F{$PROMPT_COLOR_GREEN}%b%f %K{$PROMPT_COLOR_RED}%F{$PROMPT_COLOR_WHITE}(%a)%f%k %B%m%%b${PS_SEPARATOR}"
zstyle ':vcs_info:git*+set-message:*' hooks git-vcs-set-message-hook

function pretty_pwd() {
	local CURRENT_DIRECTORY="$PWD"
	if [[ "${CURRENT_DIRECTORY:0:${#HOME}}" = "${HOME}" ]]; then
		CURRENT_DIRECTORY="~${CURRENT_DIRECTORY:${#HOME}}"
	fi

	if [ -n "$VCS_ROOT_DIR" ] && [[ "${CURRENT_DIRECTORY:0:${#VCS_ROOT_DIR}}" = "${VCS_ROOT_DIR}" ]]; then
		local VCS_ROOT_DIR_BASENAME="${VCS_ROOT_DIR##*/}"
		local VCS_ROOT_DIR_BASENAME_COLORIZED='%B${VCS_ROOT_DIR_BASENAME}%b'
		local COLORIZED_VCS_ROOT_DIR="${VCS_ROOT_DIR/%${VCS_ROOT_DIR_BASENAME}/${VCS_ROOT_DIR_BASENAME_COLORIZED}}"
		CURRENT_DIRECTORY="${COLORIZED_VCS_ROOT_DIR}${CURRENT_DIRECTORY:${#VCS_ROOT_DIR}}"
	fi

	print -P "%F{$PROMPT_COLOR_BLUE}${CURRENT_DIRECTORY}%f"
}

export PS1="%(?..%K{\$PROMPT_COLOR_RED}%F{\$PROMPT_COLOR_WHITE}%?%f%k${PS_SEPARATOR})\$(pretty_pwd)${PS_SEPARATOR}\${vcs_info_msg_0_}%F{\$PROMPT_COLOR_GREY}%*%f${NEWLINE}%(!.%F{\$PROMPT_COLOR_RED}#.%F{\$PROMPT_COLOR_YELLOW}\$)%f "

HISTFILE="${HOME}/.histfile"
HISTSIZE=10485760
SAVEHIST=10485760
bindkey '^R' history-incremental-search-backward
bindkey -e
zstyle ':completion:*' menu select
# case-insensitive,partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
bindkey '^[[Z' reverse-menu-complete
# make the delete key work at the prompt
bindkey '^[[3~' delete-char

export TERM='xterm-256color'
ZSH_COMPLETIONS_DIR="${HOME}/.zcompletions"
mkdir -p "$ZSH_COMPLETIONS_DIR"
fpath=("$ZSH_COMPLETIONS_DIR" $fpath)

compinit
bashcompinit

# load any file that ends with .zsh or .sh and is executable
for SCRIPT in "${HOME}/.zshrc.d"/**/(.|?)*(.zsh|.sh); do
	if ! [ -x "${SCRIPT}" ]; then
		continue
	fi

	source "${SCRIPT}"
done

# colorize completion listings to match LS_COLORS (set by .zshrc.d/colors.zsh
# above) — must come after that loop since this captures LS_COLORS's value
# immediately rather than referencing it live; no-ops harmlessly if LS_COLORS
# is unset
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

compinit
bashcompinit
