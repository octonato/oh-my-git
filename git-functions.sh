
function git.rebase.interactive {
  if [ $1 ]; then
    if [[ $1 =~ ^[0-9]+$ ]]; then
      git rebase -i HEAD~"$1"
    else
      git rebase -i "$1"
    fi
  else
    echo "A HEAD~{num} or branch name must be provided"
    echo
    git recent
  fi
}

alias gri=git.rebase.interactive

function git.wipbranch {
  if [ -d .git ]; then
      if [ $1 ]; then 
          git checkout -b ${GH_USER_PREFIX}${1}
      fi
  fi
}

# deprecated: use git.worktree instead
function git.workbranch {
    echo "\033[33m⚠ 'wb' is deprecated. Use 'wt' (git.worktree) instead.\033[0m"
    echo ""
    git.worktree "$@"
}

# create a working branch using git worktree
# If env variable 'GH_USER_PREFIX' is set, it's used as a prefix for the branch,
# eg: GH_USER_PREFIX=wip- results in wip-{chosen-branch-name}
function git.worktree {
    if [ -d .git ]; then
      if [ $1 ]; then
          BASE_BRANCH=`git-current-branch`
          WORKTREE_PATH="../${1}"

          git worktree add -b ${GH_USER_PREFIX}${1} "$WORKTREE_PATH"
          cd "$WORKTREE_PATH"

          read "reply?Pull upstream [upstream/$BASE_BRANCH]? [Y/n] "
          if [[ "$reply" =~ ^[Nn]$ ]]; then
            echo "Skipping pull upstream."
          else
            echo "pulling from upstream ${BASE_BRANCH}..."
            git pull upstream $BASE_BRANCH
          fi
        else
          echo "branch name must be passed, usage: git worktree some-name"
        fi
    else
      echo "Not a git repository"
    fi
}

function git.review {
    if [ -d .git ]; then
      if [ $1 ]; then 

          REPO=${PWD##*/}

          UPSTREAM_REMOTE_URL=`git remote get-url upstream`
          DIR=pr-review-$1
          cd ../
          git clone ${REPO} $DIR
          cd $DIR
          # add upstream pointing to remote
          git remote add upstream $UPSTREAM_REMOTE_URL

          # check it out using new branch
          gh po ${1}  
          cd ../$DIR
        else 
          echo "pull-request number, usage: git review 1234"
        fi
    else
      echo "Not a git repository"
    fi
}

alias gfu='git fetch upstream'
alias backport='git backport'
alias wb='git.workbranch'
alias wt='git.worktree'
alias wip='git.wipbranch'
alias gam='git commit -v --no-edit --amend'
alias gama='git commit -v --no-edit --amend -a'
alias glogf='git log --decorate --graph'

#alias glo='git pull-origin'
alias glu='git pull-upstream'
alias gpo='git push-origin'
alias gpu='git push-upstream'
alias gwip='git-wip'
alias gcm='git-commit-msg'
alias gcam='git-add-commit-msg'
alias grv='git.review'
alias gu='git undo'
alias gs='git.status'
alias gsh='git stash'

function ask { 
  MSG="$@"
  gh copilot explain $MSG
}

function git-show-files() {
  git diff --name-only HEAD^ HEAD | less -F
}


function gls() {
  if [ $# -gt 0 ]; then
    (git-power-status; git log --oneline --decorate --color=always -n $1 ) | less -r
  else
    (git-power-status; git log --oneline --decorate --color=always) | less -r
  fi
}

function git.status {
  git status
  echo
  echo "----------------------------------------------------------------"
}

function git-wip {
 if [ $1 ]; then
   MSG="wip: $@ [skip ci]"
 else
   MSG="wip [skip ci]"
 fi

 git-add-commit-msg "$MSG"
}

function git-power-status {
  git status 

  MARKED_FILES=`git ls-files -v | grep -c '^[[:lower:]]' `
  if [ $MARKED_FILES -gt 0 ]; then 
    echo
    echo "Files marked with '--assume-unchanged'"
    git ls-files -v | grep '^[[:lower:]]'
  fi
  echo
  echo "------------------------------------------------------------------------"
}

function git-commit-msg {
  MSG="$@"
  
  if [[ ${#MSG} -gt 50 ]]; then 
    echo -e "\033[31mWarning: Commit message is too large (${#MSG} characters). It should not be larger than 50\033[0m"
    gc -m "$MSG"
  else 
    gc -m "$MSG"
  fi
 
}

function git-add-commit-msg {
  ga .
  git-commit-msg $@
}

function gpof {
  echo "Are you really sure you want to do a forced push on origin? (y,N)"
  read confirm

  if [ "$confirm" = "y" ]; then
    git push-origin --force
  else 
    echo "Yeah, better so!"
  fi
  
}

function gpuf {
  echo "Are you really sure you want to do a forced push upstream? (y,N)"
  read confirm

  if [ "$confirm" = "y" ]; then
    git push-upstream --force
  else 
    echo "Yeah, better so!"
  fi
  
}

function grum {
  git fetch upstream
  git rebase upstream/main
}
