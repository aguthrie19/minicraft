#!/usr/bin/env bash

get_helpers() {
    local this_dir this_file helper

    this_file="${BASH_SOURCE[0]}"
    this_dir=$(dirname "$(realpath "$this_file")")

    for helper in "$this_dir"/hlpr_*.sh; do
        [[ "$(realpath "$helper")" == "$(realpath "$this_file")" ]] && continue
        source "$helper"
    done
}

# Only autorun from terminal, NOT as sourced library
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && { get_helpers "$@"; unset -f get_helpers; }