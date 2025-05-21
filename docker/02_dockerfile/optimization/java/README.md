# Java Spring Boot приложение

Это простое веб-приложение на Java Spring Boot, которое предоставляет информацию о системе и окружении.

## Структура проекта

- `src/` - исходный код приложения
  - `main/java/com/example/demo/` - Java-классы приложения
    - `DockerOptimizationDemoApplication.java` - точка входа приложения
    - `controller/ServerInfoController.java` - REST-контроллер с эндпоинтами:
      - `/` - возвращает простое приветствие
      - `/api/info` - возвращает информацию о сервере
      - `/health` - эндпоинт для проверки состояния приложения

- `pom.xml` - файл конфигурации Maven с зависимостями
- `Dockerfile` - неоптимизированный Dockerfile для построения образа

## Инструкции по запуску

### С использованием Docker

Для сборки и запуска приложения с использованием Docker:

```bash
# Сборка образа
docker build -t java-app:original .

# Запуск контейнера
docker run -d -p 8080:8080 --name java-app java-app:original
```

### Локальный запуск (без Docker)

Для локального запуска:

```bash
# Сборка с помощью Maven
mvn package

# Запуск приложения
java -jar target/docker-optimization-demo-0.0.1-SNAPSHOT.jar
```

## Задание

Проанализируйте предоставленный `Dockerfile` и найдите способы его оптимизации. Создайте новый файл `Dockerfile.optimized` с улучшенными инструкциями.

<details>
<summary>На что обратить внимание (раскройте после попытки самостоятельной оптимизации)</summary>

Основные проблемы, на которые следует обратить внимание:
1. Используется полный JDK образ вместо более компактного JRE
2. Maven устанавливается внутри контейнера, хотя можно использовать многоэтапную сборку
3. Активированы различные отладочные флаги Java, увеличивающие потребление ресурсов
4. Включены devtools, которые не нужны в production
5. Не используется кэширование зависимостей Maven
6. Неоптимальный порядок слоев для кэширования

Возможные оптимизации:
- Использование многоэтапной сборки с Maven в первом этапе и JRE во втором
- Отключение отладочной информации и dev-инструментов
- Оптимизация JVM параметров для контейнера
- Улучшение кэширования зависимостей Maven
- Использование более легковесных базовых образов
</details>

---

# Java Spring Boot Application

This is a simple Java Spring Boot web application that provides information about the system and environment.

## Project Structure

- `src/` - application source code
  - `main/java/com/example/demo/` - Java application classes
    - `DockerOptimizationDemoApplication.java` - application entry point
    - `controller/ServerInfoController.java` - REST controller with endpoints:
      - `/` - returns a simple greeting
      - `/api/info` - returns server information
      - `/health` - endpoint for checking application status

- `pom.xml` - Maven configuration file with dependencies
- `Dockerfile` - non-optimized Dockerfile to build the image

## Running Instructions

### Using Docker

To build and run the application using Docker:

```bash
# Build the image
docker build -t java-app:original .

# Run the container
docker run -d -p 8080:8080 --name java-app java-app:original
```

### Local Run (without Docker)

For local execution:

```bash
# Build with Maven
mvn package

# Run the application
java -jar target/docker-optimization-demo-0.0.1-SNAPSHOT.jar
```

## Assignment

Analyze the provided `Dockerfile` and find ways to optimize it. Create a new file `Dockerfile.optimized` with improved instructions.

<details>
<summary>What to pay attention to (open after attempting optimization yourself)</summary>

Main issues to consider:
1. A full JDK image is used instead of a more compact JRE
2. Maven is installed inside the container, although multi-stage build could be used
3. Various Java debug flags are activated, increasing resource consumption
4. Devtools are enabled, which are not needed in production
5. Maven dependency caching is not used
6. Suboptimal layer order for caching

Possible optimizations:
- Use multi-stage build with Maven in the first stage and JRE in the second
- Disable debug information and dev tools
- Optimize JVM parameters for containers
- Improve Maven dependency caching
- Use more lightweight base images
</details> 