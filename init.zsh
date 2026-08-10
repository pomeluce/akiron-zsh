export AKIRON_ZSH_HOME=$(cd $(dirname $0);pwd)
export AKIRON_ZSH_CACHE=${ZSH_CACHE_DIR:-$HOME/.cache/akzsh}
ZIM_CONFIG_FILE=$AKIRON_ZSH_HOME/zimrc
ZIM_HOME=$HOME/.cache/zim

if [[ ! -d ${AKIRON_ZSH_CACHE} ]]; then
  mkdir -p $AKIRON_ZSH_CACHE
fi

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
if [[ -f ${ZIM_HOME}/init.zsh ]]; then
  source ${ZIM_HOME}/init.zsh
fi

# hooks start
[[ $AKIRON_ZSH_HISTORY_SHOW == false ]] || _akzsh_history_show
[[ $AKIRON_ZSH_IN_LASTDIR == false ]] || _akzsh_in_lastdir
