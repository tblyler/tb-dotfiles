alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit -v'
alias gcl='git clone --recurse-submodules'
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gf='git fetch'
alias gfo='git fetch origin'
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gl='git pull'
alias gm='git merge'
alias gp='git push'
alias gst='git status'
alias gsu='git submodule update'
alias gwt='git worktree'
alias gwtp='git worktree prune'

function gwtc() {
	(
		set -euo pipefail
		local -r REPOS_DIR="${REPOS_DIR:-${HOME}/repos}"
		local REPO_NAME=""
		local BRANCH=""

		REPO_NAME="$(
			cd "$REPOS_DIR"
			find . -maxdepth 2 -type d -name .git -print0 | xargs -0 -r -n 12 dirname | sed 's#^\./##' | sort -f | fzf --prompt='choose a repo: '
		)"

		local -r REPO_DIR="$REPOS_DIR/$REPO_NAME"

		git -C "$REPO_DIR" worktree prune

		BRANCH="$(git -C "$REPO_DIR" branch -a --format '%(refname:short)' | (fzf --print-query --prompt='Choose a branch: ' || true))"
		if [ "$(echo "$BRANCH" | wc -l )" -eq 1 ]; then
			if ! git -C "$REPO_DIR" branch -a --format '%(refname:short)' | grep -Fx "$BRANCH"; then
				local BASE_BRANCH
				BASE_BRANCH="$(git -C "$REPO_DIR" branch -a --format '%(refname:short)' | fzf --prompt="$BRANCH doesn't exist in $REPO_NAME, which branch do you want to base it off of? ")"
				git -C "$REPO_DIR" branch "$BRANCH" "$BASE_BRANCH"
			fi
		else
			BRANCH="$(echo "$BRANCH" | tail -n 1)"
		fi

		git -C "$REPO_DIR" worktree add "$PWD/$REPO_NAME" "$BRANCH"
	)
}
