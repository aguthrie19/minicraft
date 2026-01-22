#!/usr/bin/env sh

check_wantfailneed () {
    local w want need
    want="ferium"

    for w in ${want}; do command -v "$w" >/dev/null 2>&1 || need="${need:-}${w} "; done
    if [ -n "${need:-}" ]; then echo "MISSING ${need}" >&2; exit 1; fi
}
check_wantfailneed

#lithium
#ferrite-core
#fabric-api
#viaversion
#viafabric
#inventory-essentials