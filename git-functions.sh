
function git.rebase.interactive {
    if [ $1 ] ; then
        git rebase -i HEAD~"$1"
    else
        echo "A HEAD~{num} must be provided"
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

# create a working branch, similar to `git worktree`
# but works by creating a local clone. 
# If env variable 'GH_USER_PREFIX' is set, it's used as a prefix for the branch, 
# eg: GH_USER_PREFIX=wip- results in wip-{chosen-branch-name}
function git.workbranch {
    if [ -d .git ]; then
      if [ $1 ]; then 
          git-pull-upstream
          
          REPO=${PWD##*/}

          # save remote urls for later
          UPSTREAM_REMOTE_URL=`git remote get-url upstream`
          ORIGIN_REMOTE_URL=`git remote get-url origin`

          cd ../
          git clone ${REPO} $1
          cd $1

          # local points to origin (original local checkout)
          git remote add local `git remote get-url origin`

          # remove origin and read point to remove
          git remote remove origin
          git remote add origin $ORIGIN_REMOTE_URL

          # add upstream pointing to remote
          git remote add upstream $UPSTREAM_REMOTE_URL

          # check it out using new branch
          git checkout -b ${GH_USER_PREFIX}${1}

          # copy ide settings
          copy-ide-settings ${REPO} $1          
          cd ../$1
        else 
          echo "branch name must be passed, usage: git workbranch some-name"
        fi
    else
      echo "Not a git repository"
    fi

}


alias gfu='git fetch upstream'
alias backport='git backport'
alias wb='git.workbranch'
alias wip='git.wipbranch'
alias gs='git status'
alias gamd='git commit -v --no-edit --amend'
alias glogf='git log --decorate --graph'
alias glu='git pull-upstream'
alias gpo='git push-origin'
alias gpu='git push-upstream'
alias gwip='ga . && gc -m wip'


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
  git rebase upstream/master
}