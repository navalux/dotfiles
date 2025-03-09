#!/bin/sh

set -eu

# -----------------------------------------------------------------------------
# Load library
#
# @param {string} $1 - project root path
#
load_library() {
  if [ $# -ne 1 ]; then
    msg_params_error "load_library" "$@"
    exit 1
  fi

  local lib="${1}/script/lib"

  . "${lib}/msg"
  . "${lib}/fs"
  . "${lib}/list"
}

# -----------------------------------------------------------------------------
# Get installer list
#
# @param  {string} $1 - installer direcotry
# @return {string} comma separated installer list
#
get_installer_list() {
  if [ $# -ne 1 ]; then
    msg_params_error "get_installer_list" "$@"
    exit 1
  fi

  local target="$1"
  local list=""

  local files
  files=$(mktemp)

  if [ ! -d "$target" ]; then
    msg_failure "Cannot find any installer in installer direcotry." \
                "directory = ${target}"
    exit 1
  fi

  find "$target" -type f > "$files"

  while read -r file; do
    if [ -z "$list" ]; then
      list=$(list_append "$list" "all")
    fi

    list=$(list_append "$list" "${file##"${target}/"}")
  done < "$files"

  rm "$files"

  printf "%s" "$list"
}

# -----------------------------------------------------------------------------
# Get install target from index
#
# @param  {string}  $1 - list
# @param  {integer} $2 - index
# @return {string}  install target
#
get_install_target() {
  if [ $# -ne 2 ]; then
    msg_params_error "get_install_target" "$@"
    exit 1
  fi

  local list="$1"
  local index="$2"

  if [ -z "${index#*[!0-9]*}" ]; then
    return 1
  fi

  target=$(list_at "$list" "$index")
  if [ -z "$target" ]; then
    return 1
  fi

  printf "%s" "$target"
}

# -----------------------------------------------------------------------------
# Run installer
#
# @param {string} $1 - project root path
# @param {string} $2 - target
#
run_installer() {
  if [ $# -ne 2 ]; then
    msg_params_error "run_installer" "$@"
    exit 1
  fi

  local root="$1"
  local target="$2"

  local installer="${root}/script/installer/${target}"

  local starter
  starter="install_${installer##*/installer/}"
  starter="$(printf "%s" "$starter" | tr "/" "_")"
  starter="$(printf "%s" "$starter" | tr "-" "_")"

  msg_normal "Running installer for \"${target}\""

  # shellcheck disable=SC1090
  . "$installer"
  eval "$starter" "$root"

  printf "\n"
}

# -----------------------------------------------------------------------------
# Run all installer
#
# @param {string} $1 - project root path
# @param {string} $2 - installer list
#
run_all_installer() {
  if [ $# -ne 2 ]; then
    msg_params_error "run_all_installer" "$@"
    exit 1
  fi

  local root="$1"
  local list="$2"

  local index=1
  while true; do
    target=$(list_at "$list" "$index")
    [ -z "$target" ] && break
    run_installer "$root" "$target"
    index=$((index + 1))
  done
}

# -----------------------------------------------------------------------------
# main
#
main() {
  local root
  root="$(realpath "$(dirname "$(realpath "$0")")/../")"
  load_library "$root"

  local list
  list=$(get_installer_list "${root}/script/installer")

  while true; do
    msg_select "Input installation target number." "$list"
    [ -z "$user_input" ] && break

    local target
    target=$(get_install_target "$list" "$user_input")
    [ -z "$target" ] && break

    if [ "$target" = "all" ]; then
      run_all_installer "$root" "$list"
    else
      run_installer "$root" "$target"
    fi
  done
}

main "$@"
