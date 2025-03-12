#!/bin/sh

set -eu

curl_get() {
  local file="$1"
  local url="$2"

  msg_normal "Upgrading ${file}"
  curl -Lo "$file" "$url"
  echo ""
}

main() {
  local root
  root="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")/.." && pwd -P)"

  . "${root}/script/lib/msg"

  if ! command -v curl >/dev/null 2>&1; then
    msg_error "curl command does not exists"
    exit 1
  fi

  local file
  local url

  file="${root}/config/bash/git-prompt.sh"
  url="https://github.com/git/git/raw/refs/heads/master/contrib/completion/git-prompt.sh"
  curl_get "$file" "$url"

  file="${root}/config/xfce4-terminal/base16-eighties.theme"
  url="https://github.com/tinted-theming/tinted-terminal/raw/refs/heads/main/themes/xfce4/base16-eighties.theme"
  curl_get "$file" "$url"

  file="${root}/config/alacritty/base16-eighties.toml"
  url="https://github.com/tinted-theming/tinted-terminal/raw/refs/heads/main/themes/alacritty/base16-eighties.toml"
  curl_get "$file" "$url"
}

main "$@"
