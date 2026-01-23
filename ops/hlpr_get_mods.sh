#!/usr/bin/env sh

check_wantfailneed () {
    local w want need
    want="ferium unzip zip grep realpath"

    for w in ${want}; do command -v "$w" >/dev/null 2>&1 || need="${need:-}${w} "; done
    if [ -n "${need:-}" ]; then echo "MISSING ${need}" >&2; exit 1; fi
}
check_wantfailneed


get_mods_patch_stamina_jar() {
  jar_file="stamina!-1.0.3.jar"
  jar_abs_path="$(realpath "$jar_file")"
  #jar_abs_path="$(pwd)/$jar_file"
  target_file="data/stamina/functions/stamina_tick.mcfunction"
  search_pattern="run title"

  unzip -l “$jar_file” | grep “$target_file” -q || return 1

  tmpdir=$(mktemp -d)
  unzip "$jar_file" "$target_file" -d "$tmpdir"
  #mkdir -p "${tmpdir}/$(dirname "${target_file}" )"

  if [ ! -f "${tmpdir}/${target_file}" ]; then
    echo "Error: Could not find $target_file inside $jar_file."
    rm -rf "$tmpdir"
    return 1
  fi

  if grep -q "^#.*$search_pattern" "$tmpdir/$target_file"; then
    echo "Line matching '$search_pattern' is already commented out."
  elif grep -q "$search_pattern" "$tmpdir/$target_file"; then
    echo "Commenting out '$search_pattern'..."
    # Use sed to add # to the start of lines matching "run title"
    sed -i "/$search_pattern/s/^/#/" "$tmpdir/$target_file"

    # Update the JAR
    (cd "$tmpdir" && zip -u "$jar_abs_path" "$target_file") || { rm -rf "$tmpdir"; return 1; }
    echo "Successfully updated $jar_file."
  else
    echo "Pattern '$search_pattern' not found in $target_file."
    rm -rf "$tmpdir"
    return 1
  fi
  # Clean up
  rm -rf "$tmpdir"
}


#lithium
#ferrite-core
#fabric-api
#viaversion
#viafabric
#inventory-essentials
