#!/usr/bin/env bash

is_valid_path() {
  is_in_work_tree=$(git rev-parse --is-inside-work-tree)
  is_in_git_dir=$(git rev-parse --is-inside-git-dir)

  if [[ ${is_in_work_tree} = true ]]; then
    _move_usage
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
    _help "$@"
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
