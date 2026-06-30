export GPG_TTY=$(tty)

setopt AUTO_CD SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY EXTENDED_HISTORY

# EXPORTS #
export GOPATH=$HOME/go
path=(
  ${KREW_ROOT:-$HOME/.krew}/bin
  $HOME/go/bin
  $HOME/.local/bin
  $path
)
export PATH
export EDITOR='nvim'
export K9S_EDITOR='nvim'

# Machine-specific paths, exports, and aliases (e.g. GOPRIVATE, gcloud, f3).
[[ -f "${ZDOTDIR:-$HOME}/.zshrc.local" ]] && source "${ZDOTDIR:-$HOME}/.zshrc.local"

# REPO PICKER #

GITHUB_SRC="$HOME/src/github.com"

pick-repo() {
  local repo
  repo=$(fd . "$GITHUB_SRC" --type directory --exact-depth 2 \
    | sed "s|^$GITHUB_SRC/||" \
    | fzf --prompt='repo> ')
  [[ -n "$repo" ]] && echo "$GITHUB_SRC/$repo"
}

repo-cd() {
  local dir
  dir=$(pick-repo) || return 1
  cd "$dir"
}

repo-nvim() {
  local dir
  dir=$(pick-repo) || return 1
  cd "$dir" && nvim
}

repo-cursor() {
  local dir
  dir=$(pick-repo) || return 1
  cd "$dir" && cursor .
}

# ALIASES #

alias g='git'
alias gu='g u'
alias gs='g s'
alias vi='nvim'
alias vim='nvim'
alias n='nvim'
alias k='kubectl'
alias kk='k9s --context "$(kubectl config get-contexts -o name | fzf --prompt="Select Kubernetes context: ")"'
alias kc='k ctx'
alias s='samctl'
alias t='terraform'
alias ca='cursor-agent'
alias cx='codex'
alias tp='terraform plan'
alias tv='terraform validate'
alias sit='idasenctl set sit'
alias stand='idasenctl set stand'
alias editor=nvim
alias dl=repo-cd
alias nn=repo-nvim
alias cc=repo-cursor
alias l='eza -l --icons --git -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias ..='cd ..'

[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
  && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history)
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] \
  && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

# PROMPT #

setopt prompt_subst

refresh-brew-shellenv() {
  local cache="$HOME/.cache/brew-shellenv"
  local brew
  brew=$(command -v brew) || return 1

  mkdir -p "${cache:h}"
  "$brew" shellenv > "$cache"
  source "$cache"
  echo "refreshed $cache"
}

_git_prompt_info() {
  local info branch star='' lines

  info=$(git status -sb --porcelain=v1 -uno 2>/dev/null) || return

  branch=${info#*## }
  branch=${branch%%[[:space:]]*}
  branch=${branch%%...*}

  lines=(${(f)info})
  (( ${#lines} > 1 )) && star='%F{red}*'

  [[ -n $branch ]] && print -Pn " (%F{cyan}${branch}%f${star}%f)"
}

precmd() {
  ps1_git=$(_git_prompt_info)
  print -Pn "\e]0;${PWD:t} :: \a"
}

PROMPT=' %F{blue}➜%f %B%F{magenta}%1~%f%b${ps1_git}
 %F{green}▶%f '
