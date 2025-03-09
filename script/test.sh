#!/bin/sh

check_command_exists() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: '$1' command does not exist."
    exit 1
  fi
}

main() {
  check_command_exists "file"
  check_command_exists "shellcheck"

  local root
  root=$(realpath "$(dirname "$(realpath "$0")")/../")

  find "${root}" -not -path "*/.git/*" -type f | while IFS= read -r file; \
  do \
    if test "$(file -b --mime-type "${file}")" = "text/x-shellscript";
    then
      if test "$(basename "$file")" = "24-bit-color.sh"; then
        continue
      fi

      echo "shellcheck ${file}"
      shellcheck "${file}"
    fi
  done
}

main "$@"
