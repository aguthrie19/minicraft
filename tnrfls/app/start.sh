#!/usr/bin/env sh
echo "o container entrypoint"
set -eu

#workdir should be /app of the container
srcdir=$(dirname "$0")
serverdir="/share/minicraftsrv"
serverpps_from="${srcdir}/server.properties"
serverpps_to="${serverdir}/server.properties"
modsdir="{serverdir}/mods"
configdir="{serverdir}/config"
srvtype=$SRVTYPE
serverjar="server.jar"
feriumconfig="${srcdir}/ferium_profile.json"
ferriteconf_from="${srcdir}/ferritecore.mixin.properties"
ferriteconf_to="${serverdir}/config/ferritecore.mixin.properties"
lithiumpps_from="${srcdir}/lithium.properties"
lithiumpps_to="${serverdir}/config/lithium.properties"
javaflags="${srcdir}/jvm_flags.txt"
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

(
  get_mods_cp_check ${serverpps_from} ${serverpps_to}
  rcon_password="$(cat /secrets/manual_rcon_password)" envsubst \
  < "${serverdir}/server.properties" > "${serverdir}/server.properties.tmp"
  mv "${serverdir}/server.properties.tmp" "${serverdir}/server.properties"
)

if [ ! -f "${feriumconfig}" ]; then
  cp "${feriumconfig}" "${serverdir}/ferium_profile.json" || { echo "Error: Failed to find and move config file."; exit 1; }
else
  export FERIUM_CONFIG_FILE="${feriumconfig}";
fi

ferium scan
#ferium add maybe stamina_exclamation
ferium upgrade

echo "###### passed ferium upgrade ######"
get_mods_cp_check ${ferriteconf_from} ${ferriteconf_to}
echo "###### passed ferrrite settings ######"
get_mods_cp_check ${lithiumpps_from} ${lithiumpps_to}
#get_mods_patch_stamina_jar
echo "###### passed stamina jar patch ######"
get_mods_patch_fracturedhearts
echo "###### passed fractured hearts patch ######"
get_mods_boat_craft
echo "###### passed boat craft install ######"

exec java @$javaflags -jar server.jar --nogui
