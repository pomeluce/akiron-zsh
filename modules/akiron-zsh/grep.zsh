grep-flags-available() {
    command grep "$@" "" &>/dev/null <<< ""
}

# 判断 EXC_FOLDERS 是否设置, 未设置则设置为默认值
if [[ -z "$EXC_FOLDERS" ]]; then
    # Ignore these folders (if the necessary grep flags are available)
    EXC_FOLDERS="{.bzr,CVS,.git,.hg,.svn,.idea,.tox}"
fi

# Check for --exclude-dir, otherwise check for --exclude. If --exclude
# isn't available, --color won't be either (they were released at the same
# time (v2.5): https://git.savannah.gnu.org/cgit/grep.git/tree/NEWS?id=1236f007
if grep-flags-available --color=auto --exclude-dir=.cvs; then
    GREP_OPTIONS="--color=auto --exclude-dir=$EXC_FOLDERS"
elif grep-flags-available --color=auto --exclude=.cvs; then
    GREP_OPTIONS="--color=auto --exclude=$EXC_FOLDERS"
fi

if [[ -n "$GREP_OPTIONS" ]]; then
    # export grep, egrep and fgrep settings
    alias grep="grep $GREP_OPTIONS"
    alias egrep="grep -E $GREP_OPTIONS"
    alias fgrep="grep -F $GREP_OPTIONS"
fi

# Clean up
unset GREP_OPTIONS EXC_FOLDERS
unfunction grep-flags-available
