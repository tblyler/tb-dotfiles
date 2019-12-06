export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

# oh-my-zsh {
export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="candy"
HYPHEN_INSENSITIVE="true"
export UPDATE_ZSH_DAYS=7
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="mm/dd/yyyy"
plugins=(battery catimg docker fzf git go golang grunt helm kube-ps1 kubectl minikube node npm pip ssh-agent sudo tmux)

source $ZSH/oh-my-zsh.sh
# }

# zsh {
HISTFILE="${HOME}/.histfile"
HISTSIZE=1048576
SAVEHIST=1048576
setopt \
	appendhistory \
	autocd \
	beep \
	extendedglob \
	nomatch \
	notify \
	HIST_IGNORE_DUPS \
	INC_APPEND_HISTORY \
	SHARE_HISTORY \
	HIST_REDUCE_BLANKS
# }

# general {
export LANG='en_US.UTF-8'
export TERM='xterm-256color'
export EDITOR='vim'
# if nvim is installed, effectively replace vim
if command -v nvim &> /dev/null; then
	export EDITOR='nvim'
	alias vi='nvim'
	alias vim='nvim'
	alias vimdiff="nvim -d"
	alias view="nvim -R"
fi
export VISUAL="${EDITOR}"

# use reflink cp if supported (yay CoW)
if cp --help | grep -q reflink; then
	alias cp='cp -i --reflink=auto'
else
	alias cp='cp -i'
fi
alias mv='mv -i'
alias dco='docker-compose'
alias mk='minikube'
alias k='kubectl'
alias kctx='kubectx'
alias kns='kubens'

REPOS="${HOME}/repos"

PHPCS_BIN="${REPOS}/phpcs/scripts"
if [ -d "${PHPCS_BIN}" ]; then
	export PATH="${PHPCS_BIN}:${PATH}"
fi

CARGO_ENV="${HOME}/.cargo/env"
if [ -f "${CARGO_ENV}" ]; then
	source "${CARGO_ENV}"
fi

if [ -x "${REPOS}/termpdf/termpdf" ]; then
	alias termpdf="${REPOS}/termpdf/termpdf"
fi

# add awless autocompletion if available
if command -v awless &> /dev/null; then
	source <(awless completion zsh)
fi

# add kubectl autocompletion if available
if command -v kubectl &> /dev/null; then
	source <(kubectl completion zsh)
fi

# add helm autocompletion if available
if command -v helm &> /dev/null; then
	source <(helm completion zsh)
fi

# add aws autocompletion if available
if command -v aws &> /dev/null; then
	complete -C aws_completer aws
fi

if command -v fzf &> /dev/null; then
	export FZF_DEFAULT_COMMAND='ag --skip-vcs-ignores --nocolor -g "" -l'
	export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi

NIX_SH="${HOME}/.nix-profile/etc/profile.d/nix.sh"
if [ -f "${NIX_SH}" ]; then
	source "${NIX_SH}"
fi

export GOAPPS=(
	'github.com/dgraph-io/badger/...'
	'github.com/golang/protobuf/protoc-gen-go'
	'github.com/google/huproxy/huproxyclient'
	'github.com/jedisct1/piknik'
	'github.com/junegunn/fzf'
	'github.com/schachmat/wego'
	'github.com/tomnomnom/gron'
	'github.com/wallix/awless'
	'google.golang.org/grpc'
)

case `uname` in
	"Darwin")
		pdf_join() {
			join_py="/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py"
			echo -n "Name of output file: "
			read output_file && "$join_py" -o $output_file $@ && open $output_file
		}

		if command -v gtar &> /dev/null; then
			alias tar='gtar'
		fi

		export VISUAL='nvim'

		#archey -c
		;;
	"Linux")
		#screenfetch
		alias open="xdg-open"

		# swap escape and caps lock keys if gnome
		if command -v dconf &> /dev/null; then
			if ! dconf read /org/gnome/desktop/input-sources/xkb-options | grep -q 'caps:swapescape'; then
				dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:swapescape']"
			fi
		fi
		;;
esac
# }

# load any file that ends with .zsh or .sh
for SCRIPT in "${HOME}/.zshrc.d"/**/(.|?)*(.zsh|.sh); do
	if ! [ -x "${SCRIPT}" ]; then
		continue
	fi

	source "${SCRIPT}"
done

source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
homeshick refresh 5 -q
