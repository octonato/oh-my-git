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
  local GHP_HISTORY_FILE="$HOME/.ghp"

  function _ghp_record_visit() {
    local dir="$1"
    touch "$GHP_HISTORY_FILE"
    # Remove existing entry and blank lines, then prepend
    local tmp=$(grep -Fxv "$dir" "$GHP_HISTORY_FILE" | grep -v '^[[:space:]]*$')
    echo "$dir" > "$GHP_HISTORY_FILE"
    if [[ -n "$tmp" ]]; then
      echo "$tmp" >> "$GHP_HISTORY_FILE"
    fi
  }

  function _ghp_select_recent() {
    if [[ ! -f "$GHP_HISTORY_FILE" ]] || [[ ! -s "$GHP_HISTORY_FILE" ]]; then
      echo "No recent projects."
      return 1
    fi

    local -a dirs
    local i=0
    while IFS= read -r line && (( i < 10 )); do
      [[ "$line" =~ ^[[:space:]]*$ ]] && continue
      dirs+=("$line")
      (( i++ ))
    done < "$GHP_HISTORY_FILE"

    echo "Recent projects:"
    local current_dir="$PWD"
    for (( i=1; i <= ${#dirs[@]}; i++ )); do
      local num=$((i - 1))
      local display_path="${dirs[$i]#$GITHUB_SRC/}"
      if [[ "${dirs[$i]}" == "$current_dir" ]]; then
        printf " %2d  \e[1;4m%s\e[0m\n" "$num" "$display_path"
      else
        printf " %2d  %s\n" "$num" "$display_path"
      fi
    done
    echo ""

    local input
    printf "Select number (Esc to cancel): "
    while true; do
      read -r -k 1 input
      # Esc
      if [[ "$input" == $'\e' ]]; then
        echo ""
        return 1
      fi
      # Digit
      if [[ "$input" =~ ^[0-9]$ ]] && (( input < ${#dirs[@]} )); then
        echo ""
        local idx=$((input + 1))
        _ghp_record_visit "${dirs[$idx]}"
        cd "${dirs[$idx]}"
        return 0
      fi
      # Invalid input — ignore and keep waiting
    done
  }

  function usage.ghp() {
    echo "Usage: ghp <hash-path> [options]"
    echo "       ghp                  Show recent projects"
    echo "Options:"
    echo "  -e, --edit         Open in editor ($EDITOR)"
    echo "  -n, --edit-nvim    Open in nvim"
    echo "  -g, --git          Open in Lazygit"
    echo "  -c, --command      Run command in directory"
    echo "  -i, --intellij     Open in IntelliJ"
    echo "  -b, --branch       Switch to branch. A new branch will be created in ../<branch-name> and called ${GH_USER_PREFIX}<branch-name>."
    echo "  -r, --review       Review PR. Use -r <pr-number> to review a specific PR. A new branch will be created in ../pr-review-<pr-number>."
    echo "  -s, --status       Show PR status"
    echo "  -v, --view-browser Open in browser"
    echo "  -d, --delete       Remove directory"
    echo "  -pl, --pr-list     List PRs"
    echo "  -h, --help         Show this help"
    echo "  -cl, --claude      Open Claude in project"
    echo "  -l, --list         List directory contents"
  }

  if [[ $# -eq 0 ]]; then
    _ghp_select_recent
    return
  fi

  if [ $1 ]; then
    PROJ_DIR="$GITHUB_SRC/$1"
    shift

    if [[ $# -eq 0 ]]; then
      echo "switching to $PROJ_DIR"
      _ghp_record_visit "$PROJ_DIR"
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
          -g|--git)
            shift
            (
              cd $PROJ_DIR
              lazygit
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
            _ghp_record_visit "$PROJ_DIR"
            cd $PROJ_DIR
            git.workbranch $BRANCH_NAME
            edit.current $@
            ;;
          -r|--review)
            shift
            PR_NUMBER=$1; shift
            _ghp_record_visit "$PROJ_DIR"
            cd $PROJ_DIR
            git.review $PR_NUMBER
            edit.current $@
            ;;
          -s|--status)
            shift
            (
              echo "Status for $PROJ_DIR"
              cd $PROJ_DIR
              gh pr status
            )
            ;;
          -v|--view-browser)
            shift
            (
              echo "Browse $PROJ_DIR"
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
          -h|--help)
            shift
            usage.ghp
            ;;
          -cl|--claude)
            shift
            (
              cd $PROJ_DIR
              claude
            )
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

_ghp_completions() {
  if (( CURRENT == 2 )); then
    # Complete directories recursively under $GITHUB_SRC
    _files -W "$GITHUB_SRC" -/ && return
  fi

  # After the first argument, complete options
  _alternative \
    'options:option:_values "ghp options" \
      "-e[Open in editor]" \
      "--edit[Open in editor]" \
      "-n[Open in nvim]" \
      "--edit-nvim[Open in nvim]" \
      "-c[Run command in directory]" \
      "--command[Run command in directory]" \
      "-i[Open in IntelliJ]" \
      "--intellij[Open in IntelliJ]" \
      "-b[Switch to branch]" \
      "--branch[Switch to branch]" \
      "-r[Review PR]" \
      "--review[Review PR]" \
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
