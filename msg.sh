#!/bin/bash

# msg <LEVEL> <MESSAGE>
msg() {
  RESET=$(tput sgr0)
  WIDTH=100

  COLOR_INFO=$(tput setaf 6)   # cyan
  COLOR_WARN=$(tput setaf 3)   # yellow
  COLOR_ERROR=$(tput setaf 1)   # red
  COLOR_SUCCESS=$(tput setaf 2)   # green
  COLOR_DEBUG=$(tput setaf 5)   # magenta

  if [[ $2 != "" ]]
  then
    local level=$1
    shift
  fi
  local msg="$*"

  # Выбираем цвет по уровню
  local color=$COLOR_INFO  # по умолчанию
  case "$level" in
    info|i)    color=$COLOR_INFO;level=info       ;;
    warn|w)    color=$COLOR_WARN;level=warn       ;;
    error|e)   color=$COLOR_ERROR;level=error     ;;
    success|s) color=$COLOR_SUCCESS;level=success ;;
    debug|d)   color=$COLOR_DEBUG;level=debug     ;;
    *)         color=$COLOR_INFO;level=info       ;;
  esac

  local ts=$(date '+%Y-%m-%d %H:%M:%S')
  local prefix="[${ts}] ${level^^}"

  body="| $prefix $msg"
  len=$(($WIDTH - ${#body}))
  closer="$(printf '%0.s ' $(seq $len))|"
  printf "%b%-30s%b %s%b\n" "$color" "+$(printf '%0.s-' $(seq $WIDTH))+"
  printf "%b%-30s%b %s%b\n" "$color" "$body" "$color" "$closer" "$RESET"
  printf "%b%-30s%b %s%b\n" "$color" "+$(printf '%0.s-' $(seq $WIDTH))+" "$RESET"
}
