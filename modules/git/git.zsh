# Only load if git is available
command -v git >/dev/null 2>&1 || return 0

# Let git prompt for credentials on the terminal instead of failing
export GIT_TERMINAL_PROMPT=1

# ── log color palette ───────────────────────────────────────────────────────
hashColor='#4caf50'
headColor='#ef6c00'
contentColor='#ffd54f'
dateColor='#2196f3'
authorColor='#ff5252'

# ── clone / init ────────────────────────────────────────────────────────────
alias gcl='git clone'                        # gcl <url> [dir]
alias gin='git init'

# ── add / commit ────────────────────────────────────────────────────────────
ga()   { git add "$@"; }                      # ga <path...>
alias gaa='git add --all'                    # stage all changes (incl. deletions)
gm()   { git commit -m "$*"; }               # gm <message>
gam()  { git add --all && git commit -m "$*"; } # gam <message>  stage all + commit
alias gca='git commit --amend --no-edit'     # amend last commit, keep message
gcam() { git commit --amend -m "$*"; }       # gcam <message>  amend with new message

# ── branch / checkout / switch ──────────────────────────────────────────────
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch -d'                     # gbd <branch>
alias gbD='git branch -D'                     # gbD <branch>  force delete
alias gco='git checkout'
gcb()  { git checkout -b "$@"; }              # gcb <branch> [start-point]
alias gsw='git switch'
alias gswc='git switch -c'                    # gswc <branch>

# ── push / pull / fetch ─────────────────────────────────────────────────────
alias gp='git push'                           # uses configured upstream
alias gpf='git push --force-with-lease'       # safer than --force
alias gpt='git push origin --tags'
alias gpl='git pull --ff-only'
alias gf='git fetch'
alias gfa='git fetch --all --prune'

# gfr: force-sync current branch to its remote counterpart
gfr() {
  local ref
  ref=$(git symbolic-ref --short -q HEAD) || { echo 'gfr: not on a branch' >&2; return 1; }
  git fetch --all && git reset --hard "origin/$ref"
}

# ── diff / status ───────────────────────────────────────────────────────────
alias gd='git --no-pager diff'
alias gdc='git --no-pager diff --cached'      # show staged changes
alias gs='git --no-pager status'
alias gss='git --no-pager status -s'
alias gsb='git --no-pager status -sb'

# ── remote ──────────────────────────────────────────────────────────────────
alias grv='git remote -v'
gra()  { git remote add "$@"; }               # gra <name> <url>
grmv() { git remote rename "$@"; }            # grmv <old> <new>
grrm() { git remote remove "$@"; }            # grrm <name>
grs()  { git remote set-url "$@"; }           # grs <name> <url>

# ── tag ─────────────────────────────────────────────────────────────────────
gt()  { git tag -a "$1" -m "$2"; }            # gt <tag> <message>
alias gtl='git tag -n --sort=taggerdate'      # list tags (by date)
alias gtd='git tag -d'                        # gtd <tag>  delete

# ── log ─────────────────────────────────────────────────────────────────────
git_log() {
  git --no-pager log --date=format:'%Y-%m-%d %H:%M' \
    --pretty=tformat:$1 --graph -n "${2:-10}"
}
gll()  { git_log "%C(${hashColor})%h %C(${contentColor})%s%Creset" $1; }
glla() { git_log "%C(${hashColor})%h %C(${dateColor})%cd %C(${authorColor})%cn: %C(${contentColor})%s%C(${headColor})%d%Creset" $1; }
glo()  { git --no-pager log --oneline --graph -n "${1:-15}"; }  # glo [n]  quick oneline graph
glf()  { git --no-pager log --follow --oneline -- "$1"; }       # glf <file>  history of a file

# ── show ────────────────────────────────────────────────────────────────────
alias gsh='git --no-pager show'               # gsh [commit]
alias gsn='git --no-pager show --name-only'   # gsn [commit]  changed files only
gsd() { git --no-pager show "$1" -- "$2"; }   # gsd <commit> <file>

# ── stash ───────────────────────────────────────────────────────────────────
alias gst='git stash push'                    # gst [-u] [-m msg]
alias gsta='git stash apply'                  # gsta <stash>
alias gstp='git stash pop'                    # gstp <stash>
alias gstl='git stash list'
alias gstd='git stash drop'                   # gstd <stash>
alias gstc='git stash clear'

# ── rebase ──────────────────────────────────────────────────────────────────
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'
grbi() { git rebase -i "HEAD~${1:-3}"; }      # grbi [n]  interactive rebase of last n

# ── merge ───────────────────────────────────────────────────────────────────
alias gmrg='git merge'                        # gmrg <branch>
alias gmrga='git merge --abort'
alias gmrgc='git merge --continue'

# ── cherry-pick ─────────────────────────────────────────────────────────────
alias gcp='git cherry-pick'                   # gcp <commit>
alias gcpc='git cherry-pick --continue'
alias gcpa='git cherry-pick --abort'

# ── reset / revert / undo ───────────────────────────────────────────────────
alias grh='git reset --hard'                  # grh [ref]  discard working tree
gundo() { git reset --soft "HEAD~${1:-1}"; }  # gundo [n]  undo last n commits, keep staged
alias grev='git revert'                       # grev <commit>

# ── clean untracked ─────────────────────────────────────────────────────────
alias gcln='git clean -nd'                    # dry-run preview (safe default)
alias gclnf='git clean -fd'                   # force remove untracked files + dirs

# ── conflict resolution ─────────────────────────────────────────────────────
gours()   { git checkout --ours "$@"; }       # keep local version of <files...>
gtheirs() { git checkout --theirs "$@"; }     # take incoming version of <files...>

# ── blame / reflog ──────────────────────────────────────────────────────────
alias gbl='git --no-pager blame'              # gbl <file>
alias grl='git --no-pager reflog'

# ── bisect ──────────────────────────────────────────────────────────────────
alias gbs='git bisect start'
alias gbsg='git bisect good'
alias gbsb='git bisect bad'
alias gbsr='git bisect reset'

# ── worktree ────────────────────────────────────────────────────────────────
alias gwt='git worktree'
alias gwta='git worktree add'                 # gwta <path> <branch>
alias gwtl='git worktree list'
alias gwtr='git worktree remove'              # gwtr <path>

# ── submodule ───────────────────────────────────────────────────────────────
alias gsm='git submodule'
alias gsma='git submodule add'                # gsma <url> [path]
alias gsmu='git submodule update --init --recursive'

# ── grep ────────────────────────────────────────────────────────────────────
alias gg='git grep'
