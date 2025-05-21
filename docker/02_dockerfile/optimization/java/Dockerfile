# Используем тяжеловесный образ JDK для разработки
FROM openjdk:11-jdk

# Устанавливаем Maven для сборки приложения внутри контейнера
RUN apt-get update && apt-get install -y maven

# Рабочая директория
WORKDIR /app

# Копируем весь проект
COPY . /app/

# Запускаем сборку
RUN mvn package -DskipTests

# Запускаем приложение с большим количеством отладочной информации
CMD ["java", "-Xms512m", "-Xmx1024m", "-XX:+PrintGCDetails", "-XX:+PrintGCDateStamps", \
     "-XX:+PrintGCTimeStamps", "-XX:+HeapDumpOnOutOfMemoryError", \
     "-Dspring.devtools.restart.enabled=true", \
     "-jar", "target/docker-optimization-demo-0.0.1-SNAPSHOT.jar"]

# Открываем порт
EXPOSE 8080 