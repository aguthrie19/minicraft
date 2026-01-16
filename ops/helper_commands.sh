above() (
  set -e
  local file tmp
  file="${1:?filename required}"
  tmp=$(mktemp "${file}.XXXXXX")
  
  trap 'rm -f "$tmp"' EXIT
  cat - "$file" > "$tmp" && mv "$tmp" "$file"
)
# <<'EOF' above adir/some.file
# line 1 inserted at the top
# line 2
# other lines above our file
# <adir/some.file>'s contents