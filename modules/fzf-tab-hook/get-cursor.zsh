# 用于在<tab>行为发生时获取当前的光标位置

exec < /dev/tty
oldstty=$(stty -g)
stty raw -echo min 0
echo -en "\033[6n" > /dev/tty
IFS=';' read -r -d R -A pos
stty $oldstty
row=$((${pos[1]:2} - 1))
col=$((${pos[2]} - 1))
echo "export row=$row" > $AKIRON_ZSH_CACHE/cursor
echo "export col=$col" >> $AKIRON_ZSH_CACHE/cursor
