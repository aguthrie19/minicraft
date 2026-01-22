#!/usr/bin/env sh
set -eu

srcdir=$(dirname "$0")
serverdir="/share/minicraftsrv"
srvtype=$SRVTYPE
source "${srcdir}/hlpr_get_minecraft.sh"
source "${srcdir}/hlpr_get_mods.sh"

mkdir -p "${serverdir}"
cd "${serverdir}"

if [ ! -f server.jar ]; then
  case "${srvtype}" in
    vanilla)
      get_minecraft_mojang_jar_server_from_url "1.21.8" server.jar
      ;;
    fabric)
      get_minecraft_fabric_jar_server_from_url "1.21.8" "0.18.4" "1.1.1" server.jar
      ;;
    *)
      echo "LOGIC srvtype" >&2
      exit 1
      ;;
  esac
fi

eula="${serverdir}/eula.txt"
if [ -f "${eula}" ]; then sed -i 's/^eula=false$/eula=true/' "${eula}";
else echo "eula=true" > "${eula}"; fi

ferium profile create \
-n tprofile \
--game-version 1.21.8 \
--mod-loader fabric \
-o /share/minicraftsrv/mods/

ferium scan

ferium add \
lithium \
ferrite-core \
fabric-api \
viaversion \
viafabric \
inventory-essentials

exec java -Xms1G -Xmx2G -jar server.jar nogui
