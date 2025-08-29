# Ubuntu + sudo + Java 17 + Paper 1.16.5 (build 794)
FROM ubuntu:22.04

# 1) apt update и установка sudo, Java 17 и curl
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sudo curl ca-certificates openjdk-17-jre-headless && \
    rm -rf /var/lib/apt/lists/*

# 2) Путь к jar и к данным
ENV MC_HOME=/opt/mc
ENV DATA_DIR=/dontdelete

# 3) Скачиваем Paper в область образа, НЕ в DATA_DIR
RUN mkdir -p "$MC_HOME" && \
    curl -fsSL -o "$MC_HOME/server.jar" \
      "https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar" && \
    chmod 644 "$MC_HOME/server.jar"

# 4) Рабочая директория с данными (будет том)
WORKDIR $DATA_DIR

# 5) Создаём стандартные папки (если том пустой при первом старте)
RUN mkdir -p "$DATA_DIR/world" "$DATA_DIR/plugins" "$DATA_DIR/logs" "$DATA_DIR/tmp"

# 6) Экспонируем порт Java-версии
EXPOSE 25565/tcp

# 7) Настройка памяти и путей
ENV MEMORY=5G
ENV JVM_EXTRA="-XX:+UseG1GC -Duser.home=/dontdelete -Djava.io.tmpdir=/dontdelete/tmp"

# 8) Помечаем /dontdelete как постоянные данные
VOLUME ["/dontdelete"]

# 9) Точка входа: создаёт eula.txt при первом запуске и стартует сервер
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
