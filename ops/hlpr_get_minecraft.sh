#!/usr/bin/env sh

check_wantfailneed () {
    local w want need
    want="curl jq java"

    for w in ${want}; do command -v "$w" >/dev/null 2>&1 || need="${need:-}${w} "; done
    if [ -n "${need:-}" ]; then echo "MISSING ${need}" >&2; exit 1; fi
}
check_wantfailneed

get_minecraft_mojang_jar_server_from_url () {
    # Usage: get_mojang_jar_server_from_url <version> <outputfile>
    local version outputfile manifesturl downloadurl
    version="${1:?WANTARG mojang server version}"
    outputfile="${2:?WANTARG outputfile}"

    echo "get_minecraft_mojang_jar_server_from_url"

    manifesturl=$(curl -fsSL 'https://piston-meta.mojang.com/mc/game/version_manifest.json' \
    | jq -er --arg VERSION "$version" '.versions[] | select(.id == $VERSION) | .url')
    downloadurl=$(curl -fsSL "$manifesturl" | jq -er '.downloads.server.url')
    curl -fsSL "${downloadurl:?MISSING downloadurl}" -o "$outputfile"
}

get_minecraft_fabric_jar_server_from_url () {
    # Usage: get_mojang_jar_server_from_url <fab_game_v_q> <fab_load_v_q> <fab_istal_v_q> <outputfile>
    local fab_game_v_q fab_load_v_q fab_istal_v_q outputfile
    local tmpdir fab_game_v fab_load_v fab_istal_v
    fab_game_v_q="${1:?WANTARG fabric server game version}"
    fab_load_v_q="${2:?WANTARG fabric server loader version}"
    fab_istal_v_q="${3:?WANTARG fabric server installer version}"
    outputfile="${4:?WANTARG outputfile}"

    echo "running get_minecraft_fabric_jar_server_from_url"

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT INT TERM
    curl -fsSL 'https://meta.fabricmc.net/v2/versions/game' -o "$tmpdir/fab_game_vs.json"
    curl -fsSL 'https://meta.fabricmc.net/v2/versions/loader' -o "$tmpdir/fab_load_vs.json"
    curl -fsSL 'https://meta.fabricmc.net/v2/versions/installer' -o "$tmpdir/fab_istal_vs.json"

    fab_game_v=$(jq -er --arg avar "$fab_game_v_q" '.[] | select(.version == $avar and .stable == true) | .version' "$tmpdir/fab_game_vs.json")
    fab_load_v=$(jq -er --arg avar "$fab_load_v_q" '.[] | select(.version == $avar) | .version' "$tmpdir/fab_load_vs.json")
    fab_istal_v=$(jq -er --arg avar "$fab_istal_v_q" '.[] | select(.version == $avar) | .version' "$tmpdir/fab_istal_vs.json")
    : "${fab_game_v:?MISSING fab_game_v}" "${fab_load_v:?MISSING fab_load_v}" "${fab_istal_v:?MISSING fab_istal_v}"
    # loader and installer only list most recent as “stable”

    curl -fsSL \
    "https://meta.fabricmc.net/v2/versions/loader/${fab_game_v}/${fab_load_v}/${fab_istal_v}/server/jar" \
    -o "$outputfile"

    # cleanup
    rm -rf "$tmpdir"
    trap - EXIT INT TERM
}
#fab_game_v_q="1.21.8"
#fab_load_v_q="0.18.4"
#fab_istal_v_q="1.1.1"
