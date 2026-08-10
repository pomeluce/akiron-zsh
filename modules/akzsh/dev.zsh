# Development tool aliases (only defined when the tool is installed)
if command -v nvim &> /dev/null; then
  alias v='nvim'
  alias vim='nvim'
fi
command -v npm &> /dev/null && alias n='npm'
command -v pnpm &> /dev/null && alias p='pnpm'
command -v yarn &> /dev/null && alias y='yarn'