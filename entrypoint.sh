#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-/dontdelete}"
MC_HOME="${MC_HOME:-/opt/mc}"

mkdir -p "$DATA_DIR" "$DATA_DIR/tmp" "$DATA_DIR/logs" "$DATA_DIR/plugins" "$DATA_DIR/world"

# Если EULA нет на томе — создаём и принимаем
if [ ! -f "$DATA_DIR/eula.txt" ]; then
  echo "eula=true" > "$DATA_DIR/eula.txt"
fi

# Если у тебя в репозитории лежат дефолтные конфиги, можно добавить блок копирования:
# [ -f /defaults/server.properties ] && cp -n /defaults/server.properties "$DATA_DIR/server.properties" || true
# [ -f /defaults/whitelist.json   ] && cp -n /defaults/whitelist.json   "$DATA_DIR/whitelist.json"   || true
# [ -f /defaults/ops.json         ] && cp -n /defaults/ops.json         "$DATA_DIR/ops.json"         || true

MEM="${MEMORY:-5G}"
exec java -Xms"$MEM" -Xmx"$MEM" ${JVM_EXTRA:-} -jar "$MC_HOME/server.jar" --nogui
