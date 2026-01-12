#!/usr/bin/env sh

# if this script ends, then all sub-processes end
trap 'kill $(jobs -p)' TERM EXIT

WORLD_DIR=/share/world
mkdir -p "${WORLD_DIR}"

cd "${WORLD_DIR}"

if [ -f /share/server.jar ]; then
  exec java -Xms1G -Xmx2G -jar /share/server.jar nogui
else
  echo "Minecraft server.jar not found in /share; sleeping."
  tail -f /dev/null
fi