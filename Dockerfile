# Минималистичная база
FROM debian:bullseye-slim

# 1) Базовые утилиты
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl ca-certificates bash sudo xz-utils && \
    rm -rf /var/lib/apt/lists/*

# 2) Устанавливаем JDK 16 (Temurin 16.0.2+7) из официального архива
#    Источник: GitHub releases Eclipse Adoptium (Temurin 16)
ENV JAVA_HOME=/opt/java-16
ENV PATH="${JAVA_HOME}/bin:${PATH}"
RUN set -eux; \
    curl -fsSL -o /tmp/jdk16.tar.gz \
      "https://github.com/adoptium/temurin16-binaries/releases/download/jdk-16.0.2%2B7/OpenJDK16U-jdk_x64_linux_hotspot_16.0.2_7.tar.gz" && \
    mkdir -p /opt && \
    tar -xzf /tmp/jdk16.tar.gz -C /opt && \
    ln -s /opt/jdk-16.0.2+7 "${JAVA_HOME}" && \
    rm -f /tmp/jdk16.tar.gz

# 3) Кладём серверный jar вне тома (чтобы том его не "перекрывал")
ENV MC_HOME=/opt/mc
RUN mkdir -p "${MC_HOME}"
RUN curl -fsSL -o "${MC_HOME}/server.jar" \
      "https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar"

# 4) Рабочая директория данных (сюда монтируем том на Koyeb)
ENV DATA_DIR=/dontdelete
WORKDIR ${DATA_DIR}
RUN mkdir -p "${DATA_DIR}/world" "${DATA_DIR}/plugins" "${DATA_DIR}/logs" "${DATA_DIR}/tmp"

# 5) Настройка памяти и JVM
ENV MEMORY=2G
ENV JVM_EXTRA="-XX:+UseG1GC -Duser.home=/dontdelete -Djava.io.tmpdir=/dontdelete/tmp"

# 6) Экспонируем порт Java-сервера
EXPOSE 25565/tcp

# 7) Помечаем данные как постоянные
VOLUME ["/dontdelete"]

# 8) Точка входа
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
