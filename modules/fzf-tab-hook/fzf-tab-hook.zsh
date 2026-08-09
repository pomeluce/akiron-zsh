if [[ -f "$ZIM_HOME/modules/fzf-tab/fzf-tab.zsh" ]]; then
  start_line=$(awk '/fzf-tab-complete\(\) {/{print NR;exit}' "$ZIM_HOME/modules/fzf-tab/fzf-tab.zsh")
  end_line=$(awk '/# this name must be ugly to avoid clashes/{print NR;exit}' "$ZIM_HOME/modules/fzf-tab/fzf-tab.zsh")

  # 在指定行之间插入文本
  if ((end_line == start_line + 1)); then
    sed -i "${end_line} { /^$/! s|^|  zsh \$AKIRON_ZSH_HOME/modules/fzf-tab-hook/get-cursor.zsh\n|; }" "$ZIM_HOME/modules/fzf-tab/fzf-tab.zsh"
  fi
fi
