#!/usr/bin/env sh
set -eu

#workdir should be /app of the container
srcdir=$(dirname "$0")
serverdir="/share/minicraftsrv"
modsdir="/share/minicraftsrv/mods"
srvtype=$SRVTYPE
serverjar="server.jar"
feriumconfig="${srcdir}/ferium_profile.json"
source "${srcdir}/hlpr_get_minecraft.sh"
source "${srcdir}/hlpr_get_mods.sh"

mkdir -p "${serverdir}"
mkdir -p "${modsdir}"
cd "${serverdir}"

if [ ! -f "${serverjar}" ]; then
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

if [ -f "${feriumconfig}" ]; then
  export FERIUM_CONFIG_FILE="${feriumconfig}";
  cp "${feriumconfig}" "${serverdir}/ferium_profile.json" || { echo "Error: Failed to move config file."; exit 1; }
else
  echo "ERROR: No ferium config"
  return 1
fi

#else
#  ferium profile create \
#  -n tprofile \
#  --game-version 1.21.8 \
#  --mod-loader fabric \
#  -o /share/minicraftsrv/mods/
#
#  ferium add \
#  lithium \
#  ferrite-core \
#  fabric-api \
#  viaversion \
#  viafabric \
#  no-f3 \
#  sleep-warp-updated \
#  conures-graves \
#  "stamina!" \
#  lights-out-ftf
#fi





ferium scan
#ferium add "stamina!"
ferium upgrade
echo "###### passed ferium upgrade ######"
get_mods_patch_stamina_jar
echo "###### passed stamina jar patch ######"
get_mods_patch_fracturedhearts
echo "###### passed fractured hearts patch ######"
get_mods_boat_craft
echo "###### passed boat craft install ######"

exec java -Xms1G -Xmx2G -jar server.jar nogui
