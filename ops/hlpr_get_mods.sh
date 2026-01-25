#!/usr/bin/env sh

check_wantfailneed () {
    local w want need
    want="ferium unzip zip grep realpath"

    for w in ${want}; do command -v "$w" >/dev/null 2>&1 || need="${need:-}${w} "; done
    if [ -n "${need:-}" ]; then echo "MISSING ${need}" >&2; exit 1; fi
}
check_wantfailneed


get_mods_patch_stamina_jar() {
  jar_file='mods/stamina!-1.0.3.jar'

  jar_abs_path="$(realpath "$jar_file")"
  #jar_abs_path="$(pwd)/$jar_file"
  target_file="data/stamina/function/stamina_tick.mcfunction"
  search_pattern="run title"

  unzip -l "$jar_file" | grep "$target_file" -q || { echo "Error unzip check: probably named target file incorrectly"; rm -rf "$tmpdir"; return 1; }

  tmpdir=$(mktemp -d)
  unzip "$jar_file" "$target_file" -d "$tmpdir" || { echo "Error unzip"; rm -rf "$tmpdir"; return 1; }
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

get_mods_patch_fracturedhearts() {
  #working dir should be /share/minicraftsrv/
  #patch files live in /app
  zip_name="FracturedHearts_v1_0.zip"
  zip_file="world/datapacks/$zip_name"
  url="https://cdn.modrinth.com/data/Ikdsew92/versions/Pp1rLcnp/FracturedHearts_v1_0.zip"
  patchfile_recipe="/app/beetroot_soup.json"
  patchfile_advancement="/app/health_gain.json"
  patchfile_defaults="/app/default_settings.mcfunction"
  # File paths inside the ZIP
  rm_recipe="data/fractured_hearts/recipe/enchanted_golden_apple.json"
  add_recipe="data/fractured_hearts/recipe/beetroot_soup.json"
  rm_advancement="data/fractured_hearts/advancement/health_gain.json"
  add_advancement="data/fractured_hearts/advancement/health_gain.json"
  rm_defaults="data/fractured_hearts/function/options/default_settings.mcfunction"
  add_defaults="data/fractured_hearts/function/options/default_settings.mcfunction"
  # Heart loss at 1 is more forgiving and looks cool when half a heart doesnt fill

  echo ###### precheck #####

  # 1. Pre-check: If zip exists and contains the patch, skip
  if [ -f "$zip_file" ] && unzip -l "$zip_file" | grep -q "$add_recipe"; then
    echo "Info: $zip_file is already patched."
    return 0
  else
    echo "Info: patching $zip_file."

    # 2. Download zip and patch if either: missing OR not patched
    echo "Downloading $url"
    mkdir -p "$(dirname "$zip_file")"
    curl -fsSL "$url" -o "$zip_file" || { echo "Error: Download failed"; return 1; }
    # 3. Setup temporary workspace
    {
      tmpdir=$(mktemp -d) || { echo "Error: no dir made"; return 1; }
      # 4. Create directory structure for the patch inside tmpdir
      mkdir -p "$tmpdir/$(dirname "$add_recipe")"
      mkdir -p "$tmpdir/$(dirname "$add_advancement")"
      mkdir -p "$tmpdir/$(dirname "$rm_defaults")"

      # 5. Copy local source files to temp structure
      # Searches current dir first, then /app/
      if [ -f "$patchfile_recipe" ]; then
        cp "$patchfile_recipe" "$tmpdir/$add_recipe" || return 1
      else
        echo "Error: can't find patch recipe"; return 1;
      fi

      if [ -f "$patchfile_advancement" ]; then
        cp "$patchfile_advancement" "$tmpdir/$add_advancement" || return 1
      else
        echo "Error: can't find patch advancement"; return 1;
      fi

      if [ -f "$patchfile_defaults" ]; then
        cp "$patchfile_defaults" "$tmpdir/$add_defaults" || return 1
      else
        echo "Error: can't find patch defaults"; return 1;
      fi

      # 6. Patch the ZIP
      echo "Applying patches..."

      # Delete old files
      zip -d "$zip_file" "$rm_recipe" "$rm_advancement" "$rm_defaults"

      # Use absolute path for zip to avoid issues during 'cd'
      abs_zip="$(pwd)/$zip_file"

      (
        cd "$tmpdir"
        zip -g "$abs_zip" "$add_recipe" "$add_advancement" "$add_defaults"
      )

      rm -rf "$tmpdir"
      echo "Successfully patched $zip_file."
    } || {
      # This block only runs if the above { } block fails
      err=$?
      rm -rf "$tmpdir"
      exit "$err"
    }
  fi
}

get_mods_boat_craft () {
  #working dir should be /share/minicraftsrv/
  #patch files live in /app
  zip_name="boat_craft_1.0.0.zip"
  is_installed_file="world/datapacks/$zip_name"
  want_install_file="/app/$zip_name"

  # 1. Pre-check: If zip exists
  mkdir -p "$(dirname "$is_installed_file")"
  if [ -f "$is_installed_file" ]; then
    echo "Info: datapack $is_installed_file is already installed."
    return 0
  else
    echo "Info: installing datapack $zip_file."
    cp "$want_install_file" "$is_installed_file" || return 1
  fi
}
