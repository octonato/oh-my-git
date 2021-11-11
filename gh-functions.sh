function ghp.org {
  # if we got a project folder, we just use it. 
  if [ $2 ] && [ -d $GITHUB_SRC/$1/$2 ]; then
    # drop ORG and PROJ and pass the rest
    PROJ_MASTER=$1/$2; shift; shift
    ghp $PROJ_MASTER $@ # $@ minus $1 and $2
  else
    # $1 + $2 don't make a project, try org/master
    ORG=$1; shift
    PROJ_MASTER=$ORG/$ORG/master
    if [[ -d $GITHUB_SRC/$PROJ_MASTER ]]; then
      ghp $PROJ_MASTER $@ # $@ minus $1
    else 
      ghp $ORG $@ # $@ minus $1
    fi
  fi

}

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
                  workbranch $BRANCH_NAME
                  edit.current $@
                  ;;

              -pr |--pr-checkout)
                  shift
                  PR_NUMBER=$1; shift
                  cd $PROJ_DIR
                  pr.checkout $PR_NUMBER
                  edit.current $@
                  ;; 

              -s|--status)
                  shift
                  (
                    echo "Status for $DIR"
                    cd $PROJ_DIR
                    pr.status
                  )
                  ;;

              -o|--open)
                  shift
                  (
                    echo "Browse $DIR"
                    cd $PROJ_DIR
                    pr.open
                  )
                  ;;

              -d|--delete)
                  shift
                  (
                    cd $PROJ_DIR
                    git.branch.delete .
                  )
                  ;;                  

              -D|--force-delete)
                  shift
                  (
                    cd $PROJ_DIR
                    git.branch.delete.force .
                  )
                  ;;

              -r|--remove)
                  shift
                  (
                    echo "Removing $PROJ_DIR"
                    rm -rf $PROJ_DIR
                  )
                  ;;

              -l|--pr-list)
                  shift
                  (
                    cd $PROJ_DIR
                    hub pr list $@
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
              *)
                  echo "Sorry, I don't understand '$1'"
                  shift
                  ;;
                  
          esac
      done

    fi
  fi
}


# same as _ghp_completions but starting at org level
_ghp_completions_org ()   {       
  
  SRC_ROOT=$GITHUB_SRC/$1
  #            list all projecst    | cut out root         | cut leading chars  | cut out trailing /
  GH_PROJECTS=`ls -d $SRC_ROOT/*/*/ | cut -c ${#SRC_ROOT}- | cut -c 3-          | sed 's/\/$//'`
  
  local cur
  COMPREPLY=()     
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "${GH_PROJECTS}" -- ${cur}) )

  return 0
}

_ghp_completions ()   {       
  #            list all projecst        | cut out root           | cut leading chars  | cut out trailing /
  GH_PROJECTS=`ls -d $GITHUB_SRC/*/*/*/ | cut -c ${#GITHUB_SRC}- | cut -c 3-          | sed 's/\/$//'`

  local cur
  COMPREPLY=()     
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "${GH_PROJECTS}" -- ${cur}) )

  return 0
}

complete -F _ghp_completions -o plusdirs ghp
