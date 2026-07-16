# Changing/making/removing directory
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

# `..`, `...`, ... jump up via auto_cd (set in theme-appearence.zsh)
alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias md='mkdir -p'
alias rd='rmdir'

# Create a directory and cd into it
function mkcd() { mkdir -p "$1" && cd "$1"; }

# Disk usage of entries under each given dir (default: current dir), including
# dotfiles/dotdirs, sorted by size descending. Usage: ds [dir...]
function ds() {
  local target
  for target in "${@:-.}"; do
    [[ -d $target ]] || continue
    du -sh "$target"/*(DN) 2>/dev/null
  done | sort -hr
}
compdef _files ds

function d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

# List directory contents
if command -v lsd &> /dev/null; then
  alias l='lsd -lah'
  alias ll='lsd -lh'
  alias ls='lsd --color=auto'
  alias la='lsd -lAh'
  alias lt='lsd --tree'
  alias lta='lsd -a --tree'
  function ltd()  { lsd --tree --depth "$1" "${@:2}"; }
  function ltda() { lsd -a --tree --depth "$1" "${@:2}"; }
else
  alias ls='ls --color=auto'
  alias l='ls -lah'
  alias ll='ls -lh'
  alias la='ls -lAh'
fi
