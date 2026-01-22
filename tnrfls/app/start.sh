#!/usr/bin/env sh
set -eu

srcdir=$(dirname "$0")
serverdir="/share/minicraftserv"
srvtype=$SRVTYPE
source "${srcdir}/hlpr_get_minecraft.sh"

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

exec java -Xms1G -Xmx2G -jar server.jar nogui