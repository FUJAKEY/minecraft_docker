# Debian + Temurin JDK 16 (для Paper 1.16.5) + все данные в /dontdelete
FROM debian:bullseye-slim

# Утилиты
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl ca-certificates xz-utils netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# --- Устанавливаем JDK 16 (Temurin 16.0.2+7) ---
ENV JAVA_HOME=/opt/java-16
ENV PATH="${JAVA_HOME}/bin:${PATH}"
RUN set -eux; \
    curl -fsSL -o /tmp/jdk16.tar.gz \
      "https://github.com/adoptium/temurin16-binaries/releases/download/jdk-16.0.2%2B7/OpenJDK16U-jdk_x64_linux_hotspot_16.0.2_7.tar.gz" && \
    mkdir -p /opt && \
    tar -xzf /tmp/jdk16.tar.gz -C /opt && \
    ln -s /opt/jdk-16.0.2+7 "${JAVA_HOME}" && \
    rm -f /tmp/jdk16.tar.gz

# --- Paper в области образа (не перекрывается томом) ---
ENV MC_HOME=/opt/mc
RUN mkdir -p "${MC_HOME}" && \
    curl -fsSL -o "${MC_HOME}/server.jar" \
      "https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar"

# --- Данные/том ---
ENV DATA_DIR=/dontdelete
WORKDIR ${DATA_DIR}
RUN mkdir -p "${DATA_DIR}/world" "${DATA_DIR}/plugins" "${DATA_DIR}/logs" "${DATA_DIR}/tmp"

# Если у тебя есть свой server.properties в репозитории — эта строка скопирует его в корень образа:
# (Если файла нет — закомментируй эту строку, иначе сборка упадёт.)
COPY server.properties /server.properties

# Память JVM из переменной окружения
ENV MEMORY=2G
ENV JVM_EXTRA="-XX:+UseG1GC -Duser.home=/dontdelete -Djava.io.tmpdir=/dontdelete/tmp"

# Управление перезаписью server.properties в томе:
# false — не перезаписывать, если уже есть в томе; true — перезаписать из /server.properties
ENV OVERWRITE_SERVER_PROPERTIES=false

EXPOSE 25565/tcp
VOLUME ["/dontdelete"]

# --- Точка входа: переносим /server.properties в том, принимаем EULA и стартуем ---
RUN printf '%s\n' \
  '#!/bin/sh' \
  'set -eu' \
  'DATA_DIR="${DATA_DIR:-/dontdelete}"' \
  'MC_HOME="${MC_HOME:-/opt/mc}"' \
  'mkdir -p "$DATA_DIR" "$DATA_DIR/tmp" "$DATA_DIR/logs" "$DATA_DIR/plugins" "$DATA_DIR/world"' \
  '# Перенос server.properties в том:' \
  'if [ -f /server.properties ]; then' \
  '  if [ ! -f "$DATA_DIR/server.properties" ] || [ "${OVERWRITE_SERVER_PROPERTIES:-false}" = "true" ]; then' \
  '    mv -f /server.properties "$DATA_DIR/server.properties"' \
  '  fi' \
  'fi' \
  '# Принимаем EULA, если нет' \
  '[ -f "$DATA_DIR/eula.txt" ] || echo "eula=true" > "$DATA_DIR/eula.txt"' \
  'MEM="${MEMORY:-2G}"' \
  'exec "${JAVA_HOME:-/opt/java-16}/bin/java" -Xms"$MEM" -Xmx"$MEM" ${JVM_EXTRA:-} -jar "$MC_HOME/server.jar" --nogui' \
  > /entrypoint.sh && chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
  CMD nc -z 127.0.0.1 25565 || exit 1

CMD ["/entrypoint.sh"]
