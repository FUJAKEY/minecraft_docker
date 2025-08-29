# Java 16 (совместимо с Paper 1.16.5)
FROM eclipse-temurin:16-jre

# apt update + утилиты (sudo по твоей просьбе)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sudo curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Пути
ENV MC_HOME=/opt/mc
ENV DATA_DIR=/dontdelete

# Скачиваем Paper 1.16.5 build 794 в область образа (чтобы том не "перекрывал" jar)
RUN mkdir -p "$MC_HOME" && \
    curl -fsSL -o "$MC_HOME/server.jar" \
      "https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar" && \
    chmod 644 "$MC_HOME/server.jar"

# Рабочая директория с данными сервера (сюда монтируй Volume)
WORKDIR $DATA_DIR

# Базовые папки, если том пустой
RUN mkdir -p "$DATA_DIR/world" "$DATA_DIR/plugins" "$DATA_DIR/logs" "$DATA_DIR/tmp"

# Порт Java-версии
EXPOSE 25565/tcp

# Память берём из переменной окружения
ENV MEMORY=2G
ENV JVM_EXTRA="-XX:+UseG1GC -Duser.home=/dontdelete -Djava.io.tmpdir=/dontdelete/tmp"

# Помечаем данные как постоянные
VOLUME ["/dontdelete"]

# Точка входа
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
