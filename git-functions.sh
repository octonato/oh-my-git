
function git.rebase.interactive {
    if [ $1 ] ; then
        git rebase -i HEAD~"$1"
    else
        echo "A HEAD~{num} must be provided"
        echo
        git recent
    fi
}


# create a working branch, similar to `git worktree`
# but works by creating a local clone 

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
          git checkout -b $1

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


function _pr.url() {
  hub pr list -s all -f %U -h $GITHUB_USER:$(git rev-parse --abbrev-ref HEAD)
}

function _pr.api.url() {
  PR_URL=$1
  PATH_URL=`echo ${PR_URL#*https://github.com/} | sed  's/\/pull\//\/pulls\//g'`
  echo "https://api.github.com/repos/$PATH_URL" 
}

function pr.open {
  if [ $1 ]; then
    cd $1
  fi

  PR_URL=`_pr.url`
  if [ $PR_URL ]; then
    open $PR_URL   
  fi
}

function pr.status {
  if [ $1 ]; then
    cd $1
  fi 

  PR_URL=`_pr.url`
  if [ $PR_URL ]; then
      PR_API_URL=`_pr.api.url $PR_URL`
      # call rest api
      JSON=`curl -s $PR_API_URL |  jq '{state, merged}'`
      MERGED=`echo $JSON | jq '.merged'`
      STATE=`echo $JSON | jq '.state'`
      CI_STATUS=`hub ci-status`

      echo
      echo "URL: $PR_URL" 
      echo "Merged: $MERGED" 
      echo "State: ${STATE//\"}" 
      echo "CI Stauts: $CI_STATUS"
  else
      DIR=`pwd`
      echo "No found for branch in $DIR"
  fi
}


function pr.merged {
  if [ $1 ]; then
    cd $1
  fi

  PR_URL=`_pr.url`
  if [ $PR_URL ]; then
      PR_API_URL=`_pr.api.url $PR_URL`
      # call rest api
      curl -s $PR_API_URL | jq '.merged'
  else
    echo "no PR found"
  fi
}

function pr.new {
  git-push-origin
  PR_URL=$(hub pull-request $@)
  PR_API_URL=`_pr.api.url $PR_URL`

  echo "PR URL: $PR_URL"
  echo "PR API URL: $PR_API_URL"
}

function gc.pr {
  git add .
  git commit -m $1
  pr.new -m $1
}

function git.branch.delete.force {
    if [ -d .git ]; then
      echo "Deleting branch '$(git-current-branch)' on origin"
      git push --delete origin `git-current-branch`

      # delete that folder
      DIR_TO_DELETE=`pwd`

      echo "Deleting dir '$DIR_TO_DELETE'"
      rm -rf $DIR_TO_DELETE
    else 
      echo "Not a git repository"
    fi 
  }

function git.branch.delete {
  PR_STATE=`pr.merged` 
  if [ "$PR_STATE" = "true" ]; then
      git.branch.delete.force $1
  else 
      PR_URL=`_pr.url` 
      echo "This branch $i has an open and unmerged PR"
      echo "Check it at $PR_URL"
      echo "To force a delete, call git.branch.delete.force instead"
  fi 
}

alias pr.list='hub pr list'
alias gfu='git fetch upstream'

function pr.checkout {
  git.workbranch "PR-$1"
  hub pr checkout $1
}

alias backport='git backport'
alias workbranch='git.workbranch'
alias wb='git.workbranch'

alias gamd='git commit -v -a --no-edit --amend'
alias glogf='git log --decorate --graph'
alias glu='git pull-upstream'
alias gpo='git push-origin'

function gpof {
  echo "Are you sure you want to do a forced push? (y,N)"
  read confirm

  if [ "$confirm" = "y" ]; then
    git push-origin --force
  else 
    echo "Yeah, better so!"
  fi
  
}