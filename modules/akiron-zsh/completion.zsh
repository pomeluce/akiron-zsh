# 内置 complist 模块加载
zmodload -i zsh/complist

# case insensitive (all), partial-word and substring completion
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list '' 'r:|?=**'
else
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|?=**'
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit
