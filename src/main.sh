#!/usr/bin/env bash

set -euo pipefail

_usage() {
  cat <<HELPMSG
usage: git move [<options>] <source>... <destination>
    -v, --verbose         be verbose
    -n, --dry-run         dry run
    -f, --force           force move/rename even if target exists
    -k                    skip move/rename errors
    --sparse              allow updating entries outside of the sparse-checkout cone
HELPMSG
}

_help_usage() {
  cat <<HELPMSG
usage: git help [-a|--all] [--[no-]verbose] [--[no-]external-commands] [--[no-]aliases]
   or: git help [[-i|--info] [-m|--man] [-w|--web]] [<command>|<doc>]
   or: git help [-g|--guides]
   or: git help [-c|--config]
   or: git help [--user-interfaces]
   or: git help [--developer-interfaces]

    -a, --all             print all available commands
    --external-commands   show external commands in --all
    --aliases             show aliases in --all
    -m, --man             show man page
    -w, --web             show manual in web browser
    -i, --info            show info page
    -v, --verbose         print command description
    -g, --guides          print list of useful guides
    --user-interfaces     print list of user-facing repository, command and file interfaces
    --developer-interfaces
                          print list of file formats, protocols and other developer interfaces
    -c, --config          print all configuration variable names
HELPMSG
}

is_valid_path() {
  is_in_work_tree=$(git rev-parse --is-inside-work-tree)
  is_in_git_dir=$(git rev-parse --is-inside-git-dir)

  if [[ ${is_in_work_tree} = true ]]; then
    _usage
    exit_code=128
  elif [[ ${is_in_git_dir} == true ]]; then
    echo "fatal: this operation must be run in a work tree"
    exit_code=128
  else
    echo "fatal: not a git repository (or any of the parent directories): .git"
    exit_code=129
  fi
  exit "${exit_code}"
}

main() {
  if [[ "$#" -eq 0 ]]; then
    is_valid_path
  fi

  case $1 in
  -h | --help)
    shift
    method=$(git config --get help.format) || true
    [[ -z "${method}" ]] && method="man"

    declare -A methods
    methods=(
      ["i"]="info"
      ["m"]="man"
      ["w"]="web"
    )

    VALID_FULL_OPTION='^--(info|man|web)$'
    VALID_SHORT_OPTION='^-[imw][imw]?[imw]?$'

    for arg in "$@"; do
      if [[ ${arg} =~ ${VALID_FULL_OPTION} ]]; then
        letter=$(echo "${arg}" | cut -c3)
        method=${methods[${letter}]}
      elif [[ ${arg} =~ ${VALID_SHORT_OPTION} ]]; then
        method=${methods[${arg: -1}]}
      else
        arg=$(echo "${arg}" | sed -re 's/^-{0,2}//g')
        echo "error: unknown switch \`${arg}'"
        _help_usage
        exit 129
      fi
    done

    # use mv man page until move man page created
    git help mv "--${method}"
    return 0
    ;;
  -V | --version)
    # shellcheck disable=2154
    echo "${GITMOVE_VERSION}"
    return 0
    ;;
  *)
    echo "sorry, this command is not supported yet!"
    ;;
  esac
}

main "$@"
