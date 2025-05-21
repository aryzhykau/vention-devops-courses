# Go-приложение

Это простой веб-сервер на Go, который предоставляет информацию о системе и окружении.

## Структура проекта

- `main.go` - исходный код приложения с маршрутами:
  - `/` - возвращает простое приветствие
  - `/api/info` - возвращает информацию о сервере (hostname, версия Go, ОС, и т.д.)
  - `/health` - эндпоинт для проверки состояния приложения

- `go.mod` - файл с зависимостями Go модуля
- `Dockerfile` - неоптимизированный Dockerfile для построения образа

## Инструкции по запуску

### С использованием Docker

Для сборки и запуска приложения с использованием Docker:

```bash
# Сборка образа
docker build -t go-app:original .

# Запуск контейнера
docker run -d -p 8080:8080 --name go-app go-app:original
```

### Локальный запуск (без Docker)

Для локального запуска:

```bash
# Загрузка зависимостей и сборка
go build -o main .

# Запуск приложения
./main
```

## Задание

Проанализируйте предоставленный `Dockerfile` и найдите способы его оптимизации. Создайте новый файл `Dockerfile.optimized` с улучшенными инструкциями.

<details>
<summary>На что обратить внимание (раскройте после попытки самостоятельной оптимизации)</summary>

Основные проблемы, на которые следует обратить внимание:
1. Используется большой базовый образ вместо более компактных альтернатив
2. Устанавливаются лишние системные утилиты и инструменты разработки
3. Не используется многоэтапная сборка (multi-stage build)
4. Приложение запускается с правами root
5. Не используются флаги оптимизации при сборке Go-приложения
6. Неоптимальный порядок слоев для кэширования

Возможные оптимизации:
- Использование многоэтапной сборки с базовым scratch или alpine образом
- Статическая компиляция Go-приложения без CGO
- Запуск от непривилегированного пользователя
- Удаление лишних инструментов разработки из финального образа
</details>

---

# Go Application

This is a simple Go web server that provides information about the system and environment.

## Project Structure

- `main.go` - application source code with routes:
  - `/` - returns a simple greeting
  - `/api/info` - returns server information (hostname, Go version, OS, etc.)
  - `/health` - endpoint for checking application status

- `go.mod` - Go module dependencies file
- `Dockerfile` - non-optimized Dockerfile to build the image

## Running Instructions

### Using Docker

To build and run the application using Docker:

```bash
# Build the image
docker build -t go-app:original .

# Run the container
docker run -d -p 8080:8080 --name go-app go-app:original
```

### Local Run (without Docker)

For local execution:

```bash
# Download dependencies and build
go build -o main .

# Run the application
./main
```

## Assignment

Analyze the provided `Dockerfile` and find ways to optimize it. Create a new file `Dockerfile.optimized` with improved instructions.

<details>
<summary>What to pay attention to (open after attempting optimization yourself)</summary>

Main issues to consider:
1. A large base image is used instead of more compact alternatives
2. Extra system utilities and development tools are installed
3. Multi-stage build is not used
4. The application runs with root privileges
5. Optimization flags are not used when building the Go application
6. Suboptimal layer order for caching

Possible optimizations:
- Use multi-stage build with a base scratch or alpine image
- Static compilation of Go application without CGO
- Run as a non-privileged user
- Remove unnecessary development tools from the final image
</details> 