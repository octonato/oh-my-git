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
    echo "Usage: ghp <hash-path> [options]"
    echo "Options:"
    echo "  -e, --edit         Open in editor ($EDITOR)"
    echo "  -n, --edit-nvim    Open in nvim"
    echo "  -c, --command      Run command in directory"
    echo "  -i, --intellij     Open in IntelliJ"
    echo "  -b, --branch       Switch to branch. A new branch will be created in ../<branch-name> and called ${GH_USER_PREFIX}<branch-name>."
    echo "  -r, --review       Review PR. Use -r <pr-number> to review a specific PR. A new branch will be created in ../pr-review-<pr-number>."
    echo "  -s, --status       Show PR status"
    echo "  -v, --view-browser Open in browser"
    echo "  -d, --delete       Remove directory"
    echo "  -pl, --pr-list     List PRs"
    echo "  -g, --go-to        Go to directory"
    echo "  -h, --help         Show this help"
    echo "  -l, --list         List directory contents"
  }

  if [ $1 ]; then
    DIR=$1; shift
    PROJ_DIR=$DIR

    if [[ $# -eq 0 ]]; then
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
          -r|--review)
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
              qrm -rf $PROJ_DIR
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
          -l|--list)
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

# Zsh completion for ghp command
_ghp_completions() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _alternative \
    'paths:path:_files -W "~" -/' \
    'options:option:_values "ghp options" \
      "-e[Open in editor ($EDITOR)]" \
      "--edit[Open in editor ($EDITOR)]" \
      "-n[Open in nvim]" \
      "--edit-nvim[Open in nvim]" \
      "-c[Run command in directory]" \
      "--command[Run command in directory]" \
      "-i[Open in IntelliJ]" \
      "--intellij[Open in IntelliJ]" \
      "-b[Switch to branch. A new branch will be created in ../<branch-name> and called ${GH_USER_PREFIX}<branch-name>]" \
      "--branch[Switch to branch. A new branch will be created in ../<branch-name> and called ${GH_USER_PREFIX}<branch-name>]" \
      "-r[Review PR. Use -r <pr-number> to review a specific PR. A new branch will be created in ../pr-review-<pr-number>]" \
      "--review[Review PR. Use -r <pr-number> to review a specific PR. A new branch will be created in ../pr-review-<pr-number>]" \
      "-s[Show PR status]" \
      "--status[Show PR status]" \
      "-v[Open in browser]" \
      "--view-browser[Open in browser]" \
      "-d[Remove directory]" \
      "--delete[Remove directory]" \
      "-pl[List PRs]" \
      "--pr-list[List PRs]" \
      "-g[Go to directory]" \
      "--go-to[Go to directory]" \
      "-h[Show help]" \
      "--help[Show help]" \
      "-l[List directory contents]" \
      "--list[List directory contents]"'
}

compdef _ghp_completions ghp