# Generic aliases and small utility functions

# Allow aliases to expand after sudo (trailing space enables it)
alias sudo='sudo '

# Pager-aware cat replacement
command -v bat &> /dev/null && alias cat='bat -p'

# Filesystem operation shortcuts
alias rrf='rm -rf'
alias lnk='ln -s'
alias rlnk='ln -snf'

# Print the real path of one or more commands on $PATH. Usage: rp cmd...
function rp() {
  local cmd
  for cmd in "$@"; do realpath "$(command -v -- "$cmd")"; done
}

# Reload the current shell (re-reads config)
function reload() { exec zsh; }

# Print $PATH one entry per line
function path() { print -l ${(s/:/)PATH}; }

# Show listening TCP ports (uses ss if available, else lsof)
function ports() {
  if command -v ss &> /dev/null; then
    ss -tlnp
  elif command -v lsof &> /dev/null; then
    lsof -i -P -n | grep LISTEN
  fi
}

# Show local IP addresses (LAN), one per line. For public IP: curl ifconfig.me
function localip() {
  local -a ips=($(hostname -I))
  print -l $ips
}
