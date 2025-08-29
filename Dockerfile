# Ubuntu + sudo + Java 17 + Paper 1.16.5 (build 794)
FROM ubuntu:22.04

# 1) apt update и установка sudo, Java 17 и curl
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sudo curl ca-certificates openjdk-17-jre-headless && \
    rm -rf /var/lib/apt/lists/*

# 2) Все данные сервера — в /dontdelete
WORKDIR /dontdelete

# 3) Принять EULA (если файл уже есть на томе — не трогаем)
RUN [ ! -f eula.txt ] && echo "eula=true" > eula.txt || true

# 4) Скачиваем Paper 1.16.5 build 794 как server.jar
RUN curl -fsSL \
  -o server.jar \
  "https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar" \
  && chmod 644 server.jar

# 5) Создаём стандартные директории (на случай чистого тома)
RUN mkdir -p /dontdelete/world /dontdelete/plugins /dontdelete/logs /dontdelete/tmp

# 6) Экспонируем порт Java-версии
EXPOSE 25565/tcp

# 7) Память из переменной окружения MEMORY (по умолчанию 2G)
ENV MEMORY=5G
# Доп. флаги: всё складываем в /dontdelete, включая кэш/временные файлы Java
ENV JVM_EXTRA="-XX:+UseG1GC -Duser.home=/dontdelete -Djava.io.tmpdir=/dontdelete/tmp"

# 8) Подсказываем рантайму, что это постоянные данные
VOLUME ["/dontdelete"]

# 9) Старт: память = $MEMORY, все пути внутри /dontdelete
CMD sh -c 'exec java -Xms${MEMORY:-2G} -Xmx${MEMORY:-2G} ${JVM_EXTRA} -jar server.jar --nogui'
