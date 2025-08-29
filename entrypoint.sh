#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-/dontdelete}"
MC_HOME="${MC_HOME:-/opt/mc}"

mkdir -p "$DATA_DIR" "$DATA_DIR/tmp" "$DATA_DIR/logs" "$DATA_DIR/plugins" "$DATA_DIR/world"

# EULA принимаем, если файла нет (если уже есть — остаётся как есть)
if [ ! -f "$DATA_DIR/eula.txt" ]; then
  echo "eula=true" > "$DATA_DIR/eula.txt"
fi

MEM="${MEMORY:-5G}"
exec java -Xms"$MEM" -Xmx"$MEM" ${JVM_EXTRA:-} -jar "$MC_HOME/server.jar" --nogui
