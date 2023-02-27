#!/usr/bin/env bash

_move_usage() {
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

_help() {
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
}
