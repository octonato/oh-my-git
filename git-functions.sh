
alias gfu='git fetch upstream'
alias backport='git backport'
alias wt='git.worktree'
alias gtr='git.worktree.remove'
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
          local PR_NUMBER=$1
          local BRANCH_NAME=$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName')
          local DIR_NAME="${BRANCH_NAME##*/}"
          local WORKTREE_PATH="../$DIR_NAME"

          git worktree add "$WORKTREE_PATH" --detach
          cd "$WORKTREE_PATH"
          gh pr checkout "$PR_NUMBER"
        else
          echo "pull-request number, usage: git review 1234"
        fi
    else
      echo "Not a git repository"
    fi
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



# delete a branch directory, handling both worktrees and hard forks
# Check a git directory for potential data loss.
# Returns warnings via stdout. Empty output means safe to delete.
# Used by git.delete.branch and git.worktree.remove
# — if changed here, review both callers.
function _git.check.data.loss {
    local dir="$1"
    local warnings=""

    if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
      warnings="${warnings}  - Has uncommitted/unstaged changes\n"
    fi

    local remote_branch=$(git -C "$dir" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [ -z "$remote_branch" ]; then
      warnings="${warnings}  - No remote tracking branch (no backup)\n"
    else
      git -C "$dir" fetch --quiet 2>/dev/null
      local local_rev=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
      local remote_rev=$(git -C "$dir" rev-parse @{upstream} 2>/dev/null)
      if [ "$local_rev" != "$remote_rev" ]; then
        warnings="${warnings}  - Local differs from remote (unpushed commits)\n"
      fi
    fi

    echo "$warnings"
}

# Prompt user if there are data loss warnings. Returns 0 if safe to proceed, 1 if aborted.
# Used by git.delete.branch and git.worktree.remove
# — if changed here, review both callers.
function _git.confirm.data.loss {
    local dir="$1"
    local warnings=$(_git.check.data.loss "$dir")

    if [ -n "$warnings" ]; then
      echo "Warning: potential data loss in $dir:"
      echo "$warnings"
      echo -n "Continue? (y/N) "
      read -r confirm
      if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Aborted."
        return 1
      fi
    fi
    return 0
}

function git.delete.branch {
    local dir="$1"
    if [ ! -d "$dir" ]; then
      echo "Directory not found: $dir"
      return 1
    fi

    if [ -f "$dir/.git" ]; then
      # It's a worktree, remove it properly via gtr from the main worktree
      local WORKTREE_NAME=$(basename "$dir")
      local MAIN_DIR=$(git -C "$dir" worktree list --porcelain | head -1 | sed 's/^worktree //')
      echo "Removing worktree $WORKTREE_NAME"
      (
        cd "$MAIN_DIR"
        gtr "../$WORKTREE_NAME"
      )
    else
      _git.confirm.data.loss "$dir" || return 0
      echo "Removing $dir"
      rm -rf "$dir"
    fi
}


# remove a worktree and its branch
function git.worktree.remove {
    if [ -d .git ]; then
      if [ $1 ]; then
          WORKTREE_PATH="$1"
          BRANCH_NAME=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null)

          _git.confirm.data.loss "$WORKTREE_PATH" || return 0

          git worktree remove --force "$WORKTREE_PATH"
          if [ "$BRANCH_NAME" != "HEAD" ] && [ -n "$BRANCH_NAME" ]; then
            git branch -D "$BRANCH_NAME"
          fi
        else
          echo "path must be passed, usage: git.worktree.remove ../some-name"
        fi
    else
      echo "Not a git repository"
    fi
}
