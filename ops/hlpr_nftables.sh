nftcfg_add2chain () {
    # Usage: nftcfg_add2chain <original_config> <module_path> <target_chain> <family_table_chain>
    local origconfig module2add chain2add fmlytablchyn
    origconfig="${1:?WANTARG original config path}"
    module2add="${2:?WANTARG module path}"
    chain2add="${3:?WANTARG chain name from module}"
    fmlytablchyn="${4:?WANTARG family table chain}"

    nft -f "$module2add"
    nft add rule "$fmlytablchyn" jump "$chain2add"

    {
        header=(
            "#!/usr/sbin/nft -f"
            "flush ruleset"
            ""
            "include \"$module2add\""
            ""
        )
        printf '%s\n' "${header[@]}"
        nft list ruleset
    } > "${origconfig}.new"

    nft -c -f "${origconfig}.new"
    cp "$origconfig" "${origconfig}.old"
    mv "${origconfig}.new" "$origconfig"
}
# notice EOF MUST be alone on the line, NO leading spaces