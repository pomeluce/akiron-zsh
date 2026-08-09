mime=$(file -bL --mime-type "$1")
category=${mime%%/*}
if [ -d "$1" ]; then
  exa -l --no-user --no-time --icons "$1" 2>/dev/null || ls --color=always "$1" 2>/dev/null || ls -G "$1"
elif [ "$category" = text ]; then
  (bat -p --color=always "$1" || cat "$1") 2>/dev/null | head -1000
elif [ "$category" = image ]; then
  command -v ueberzug >/dev/null 2>&1 && zsh $AKIRON_ZSH_HOME/modules/fzf/img-preview.zsh "$1"|| img2txt "$1"
else
  echo $1 is a $category file
fi
