if [ -f "${HOME}/.zshrc.d/init" ]; then
	source "${HOME}/.zshrc.d/init"
fi

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"
if [ -d "${HOME}/bin" ]; then
	export PATH="${HOME}/bin:${PATH}"
fi

if command -v go &> /dev/null; then
	GOPATH="$(go env GOPATH)"
	if [ -d "${GOPATH}" ]; then
		export GOPATH
		export PATH="${GOPATH}/bin:${PATH}"
	fi
fi

# oh-my-zsh {
export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="candy"
HYPHEN_INSENSITIVE="true"
export UPDATE_ZSH_DAYS=7
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="mm/dd/yyyy"
plugins=(
	aws
	autojump
	battery
	brew
	catimg
	common-aliases
	copydir
	copyfile
	docker
	docker-compose
	encode64
	fzf
	git
	git-extras
	golang
	grunt
	helm
	kube-ps1
	kubectl
	minikube
	node
	npm
	osx
	pass
	pip
	pod
	ssh-agent
	sudo
	tmux
	xcode
	zsh-autosuggestions
	zsh-syntax-highlighting
)


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
if 2>&1 cp --help | grep -q reflink; then
	alias cp='cp -i --reflink=auto'
else
	alias cp='cp -i'
fi

alias mv='mv -i'

# if rootless docker has a unix domain socket, use it!
if [ -e "${XDG_RUNTIME_DIR}/docker.sock" ]; then
	export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/docker.sock"
fi

if command -v docker-compose &> /dev/null; then
	alias dco='docker-compose'
fi

if command -v minikube &> /dev/null; then
	alias mk='minikube'
fi

if command -v kubectl &> /dev/null; then
	alias k='kubectl'
fi

if command -v kubectx &> /dev/null; then
	alias kctx='kubectx'
fi

if command -v kubens &> /dev/null; then
	alias kns='kubens'
fi

CARGO_ENV="${HOME}/.cargo/env"
if [ -f "${CARGO_ENV}" ]; then
	source "${CARGO_ENV}"
fi

# add awless autocompletion if available
if command -v awless &> /dev/null; then
	source <(awless completion zsh)
fi

if command -v fzf &> /dev/null; then
	export FZF_DEFAULT_COMMAND='ag --skip-vcs-ignores --nocolor -g "" -l'
	export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi

case "$(uname)" in
	"Darwin")
		pdf_join() {
			join_py="/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py"
			echo -n "Name of output file: "
			read output_file && "$join_py" -o $output_file $@ && open $output_file
		}

		if command -v gtar &> /dev/null; then
			alias tar='gtar'
		fi

		if command -v gsed &> /dev/null; then
			alias sed='gsed'
		fi
		;;
	"Linux")
		alias open="xdg-open"
		;;
esac
# }

source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
homeshick refresh 5 -q

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# load any file that ends with .zsh or .sh and is executable
for SCRIPT in "${HOME}/.zshrc.d"/**/(.|?)*(.zsh|.sh); do
	if ! [ -x "${SCRIPT}" ]; then
		continue
	fi

	source "${SCRIPT}"
done
