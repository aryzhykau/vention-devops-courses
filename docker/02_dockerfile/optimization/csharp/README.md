# C# ASP.NET Core приложение

Это простое веб-приложение на C# ASP.NET Core, которое предоставляет информацию о системе и окружении.

## Структура проекта

- `Program.cs` - основной файл приложения с маршрутами:
  - `/` - возвращает простое приветствие
  - `/api/info` - возвращает информацию о сервере
  - `/health` - эндпоинт для проверки состояния приложения

- `Dockerfile` - неоптимизированный Dockerfile для построения образа

## Инструкции по запуску

### С использованием Docker

Для сборки и запуска приложения с использованием Docker:

```bash
# Сборка образа
docker build -t csharp-app:original .

# Запуск контейнера
docker run -d -p 80:80 --name csharp-app csharp-app:original
```

### Локальный запуск (без Docker)

Для локального запуска:

```bash
# Восстановление зависимостей и запуск
dotnet run
```

## Задание

Проанализируйте предоставленный `Dockerfile` и найдите способы его оптимизации. Создайте новый файл `Dockerfile.optimized` с улучшенными инструкциями.

<details>
<summary>На что обратить внимание (раскройте после попытки самостоятельной оптимизации)</summary>

Основные проблемы, на которые следует обратить внимание:
1. Используется полный образ SDK вместо более компактного runtime
2. Устанавливаются лишние системные утилиты и инструменты разработки
3. Не используется многоэтапная сборка (multi-stage build)
4. Приложение собирается в режиме Debug, а не Release
5. Включены различные отладочные параметры и переменные окружения
6. Используется dotnet watch, который предназначен для разработки, а не для production

Возможные оптимизации:
- Использование многоэтапной сборки с SDK для компиляции и ASP.NET Runtime для запуска
- Сборка в режиме Release для оптимизации производительности
- Запуск от непривилегированного пользователя
- Удаление лишних инструментов и отладочных параметров
- Оптимизация слоев для лучшего кэширования
</details>

---

# C# ASP.NET Core Application

This is a simple C# ASP.NET Core web application that provides information about the system and environment.

## Project Structure

- `Program.cs` - main application file with routes:
  - `/` - returns a simple greeting
  - `/api/info` - returns server information
  - `/health` - endpoint for checking application status

- `Dockerfile` - non-optimized Dockerfile to build the image

## Running Instructions

### Using Docker

To build and run the application using Docker:

```bash
# Build the image
docker build -t csharp-app:original .

# Run the container
docker run -d -p 80:80 --name csharp-app csharp-app:original
```

### Local Run (without Docker)

For local execution:

```bash
# Restore dependencies and run
dotnet run
```

## Assignment

Analyze the provided `Dockerfile` and find ways to optimize it. Create a new file `Dockerfile.optimized` with improved instructions.

<details>
<summary>What to pay attention to (open after attempting optimization yourself)</summary>

Main issues to consider:
1. A full SDK image is used instead of a more compact runtime
2. Extra system utilities and development tools are installed
3. Multi-stage build is not used
4. The application is built in Debug mode, not Release
5. Various debug parameters and environment variables are enabled
6. Using dotnet watch, which is intended for development, not production

Possible optimizations:
- Use multi-stage build with SDK for compilation and ASP.NET Runtime for running
- Build in Release mode for performance optimization
- Run as a non-privileged user
- Remove unnecessary tools and debug parameters
- Optimize layers for better caching
</details> 