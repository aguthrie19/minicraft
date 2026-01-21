get_helpers() {
    local this_dir this_file helper

    this_file="${BASH_SOURCE[0]}"
    this_dir=$(dirname "$(realpath "$this_file")")

    for helper in "$this_dir"/*.sh; do
        [[ "$(realpath "$helper")" == "$(realpath "$this_file")" ]] && continue
        source "$helper"
    done
}

get_helpers
unset -f get_helpers