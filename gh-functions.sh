function edit.current() {
  while [[ $# -gt 0 ]]
  do
    case $1 in
      -e|--edit)
        shift
        edit .
        ;;

      -i|--intellij)
          shift
          ij 
          ;;
    esac
  done
}

function ghp() {

  function usage.ghp() {
    echo "TODO: usage"
  }
  
  if [ $1 ] && [ -d $GITHUB_SRC/$1 ]; then
    
    DIR=$1; shift
    PROJ_DIR=$GITHUB_SRC/$DIR

    if [[ $# -eq 0 ]]; then
      ORG=`echo $DIR | cut -d "/" -f 1`
      ORG_DIR=$GITHUB_SRC/$ORG
      if [ -f $ORG_DIR/.zshrc ]; then
        source $ORG_DIR/.zshrc
      fi
      echo "switching to $PROJ_DIR"
      cd $PROJ_DIR
    else
   
      while [[ $# -gt 0 ]]
      do
          case $1 in

              -e|--edit)
                  shift
                  (
                    cd $PROJ_DIR
                    edit .
                  )
                  ;;
              -n|--edit-nvim)
                  shift
                  (
                    cd $PROJ_DIR
                    nvim .
                  )
                  ;;
              -c|--command)
                  shift
                  (
                    cd $PROJ_DIR
                    ${@}
                  )
                  shift $#
                  ;;                  

              -i|--intellij)
                  shift
                  (
                    cd $PROJ_DIR
                    ij
                  )
                  ;;

              -b|--branch)
                  shift
                  BRANCH_NAME=$1; shift
                  cd $PROJ_DIR
                  git.workbranch $BRANCH_NAME
                  edit.current $@
                  ;;

              -r |--review)
                  shift
                  PR_NUMBER=$1; shift
                  cd $PROJ_DIR
                  git.review $PR_NUMBER
                  edit.current $@
                  ;; 

              -s|--status)
                  shift
                  (
                    echo "Status for $DIR"
                    cd $PROJ_DIR
                    gh pr status
                  )
                  ;;

              -v|--view-browser)
                  shift
                  (
                    echo "Browse $DIR"
                    cd $PROJ_DIR
                    gh pr view -w
                  )
                  ;;

              -d|--delete)
                  shift
                  (
                    echo "Removing $PROJ_DIR"
                    rm -rf $PROJ_DIR
                  )
                  ;;

              -pl|--pr-list)
                  shift
                  (
                    cd $PROJ_DIR
                    if [ -d .git ]; then 
                      gh pr list
                    elif [ -d main ]; then
                      cd main 
                      gh pr list
                    elif [ -d master ]; then 
                      cd master 
                      gh pr list
                    else 
                      gh pr list
                    fi
                  )
                  ;;
              
              -g|--go-to)
                  shift
                  cd $PROJ_DIR
                  ;;

              -h|--help)
                  shift
                  usage.ghp
                  ;;

              -l | --list)
              shift
                  (
                    cd $PROJ_DIR
                    ls -l
                  )
                  ;;
              *)
                  echo "Sorry, I don't understand '$1'"
                  shift
                  ;;
                  
          esac
      done

    fi
  fi
}


_ghp_completions ()   {    

  echo "..."

  GH_PROJECTS=`ls -d $GITHUB_SRC/*/*/*/ | cut -c ${#GITHUB_SRC}- | cut -c 3-          | sed 's/\/$//'`


  local cur
  COMPREPLY=()     
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "${GH_PROJECTS}" -- ${cur}) )

  return 0
}

complete -F _ghp_completions -o plusdirs ghp
