# Основы Docker Compose

В этом практическом задании вы познакомитесь с Docker Compose - инструментом для определения и запуска многоконтейнерных приложений Docker. Вы научитесь создавать файл `docker-compose.yml`, запускать и управлять несколькими связанными контейнерами.

## Описание задания

Вам необходимо создать и настроить простое многоконтейнерное приложение, включающее веб-сервер и базу данных. По ходу выполнения вы познакомитесь с основными концепциями Docker Compose:
- определение сервисов
- настройка сетевого взаимодействия
- монтирование томов
- управление запущенными контейнерами

## Предварительные требования

- Установленный Docker Engine
- Установленный Docker Compose
- Базовые навыки работы с командной строкой

## Упражнение 1: Создание и запуск простого приложения

### Шаг 1: Изучите структуру проекта

В директории проекта уже подготовлены следующие файлы:
- `docker-compose.yml` - конфигурация для Docker Compose
- `web/` - директория с файлами для веб-сервера
  - `index.html` - простая демонстрационная страница
  - `Dockerfile` - для создания образа веб-сервера

### Шаг 2: Изучите файл docker-compose.yml

Откройте файл `docker-compose.yml` и ознакомьтесь с его содержимым. В нем описаны два сервиса:
- `web` - сервис на базе Nginx, который будет обслуживать статический контент
- `db` - сервис Redis, который будет использоваться как база данных

### Шаг 3: Запустите приложение

```bash
# Запустите сервисы в фоновом режиме
docker-compose up -d
```

### Шаг 4: Проверьте работу приложения

```bash
# Проверьте, что контейнеры запущены
docker-compose ps

# Откройте в браузере http://localhost:80 для доступа к веб-сервису
```

### Шаг 5: Просмотрите логи

```bash
# Посмотрите логи всех сервисов
docker-compose logs

# Посмотрите логи только веб-сервера
docker-compose logs web
```

### Шаг 6: Остановите приложение

```bash
# Остановите и удалите контейнеры
docker-compose down
```

## Упражнение 2: Модификация и перезапуск

### Задание:
1. Измените содержимое файла `web/index.html`
2. Измените порт, на котором доступен веб-сервис (в файле `docker-compose.yml`)
3. Перезапустите сервисы и проверьте изменения

```bash
# Перезапустите сервисы с измененной конфигурацией
docker-compose up -d

# Проверьте, что изменения вступили в силу
# Откройте в браузере http://localhost:<новый_порт>
```

## Упражнение 3: Взаимодействие с базой данных

### Задание:
1. Подключитесь к контейнеру с Redis
2. Добавьте тестовые данные
3. Проверьте, что данные сохранены

```bash
# Подключитесь к контейнеру Redis
docker-compose exec db redis-cli

# Внутри redis-cli добавьте тестовые данные
SET testkey "Hello from Redis!"
GET testkey

# Выйдите из redis-cli
exit
```

## Бонусное задание

Модифицируйте `docker-compose.yml`, чтобы:
1. Добавить постоянное хранение данных для Redis через volume
2. Добавить переменные окружения для настройки Redis
3. Добавить третий сервис - например, phpMyAdmin или другой инструмент для работы с Redis (например, RedisInsight)

## Завершение работы

По окончании работы, не забудьте остановить и удалить контейнеры:

```bash
docker-compose down
```

## Проверка понимания

После выполнения упражнений, ответьте на следующие вопросы:
1. Какие преимущества дает использование Docker Compose по сравнению с запуском отдельных контейнеров вручную?
2. Как Docker Compose обеспечивает сетевое взаимодействие между контейнерами?
3. Какие типы томов можно использовать в Docker Compose и для чего они нужны?

---

# Docker Compose Basics

In this practical assignment, you will familiarize yourself with Docker Compose - a tool for defining and running multi-container Docker applications. You will learn to create a `docker-compose.yml` file, launch, and manage multiple connected containers.

## Assignment Description

You need to create and configure a simple multi-container application that includes a web server and a database. Along the way, you will become familiar with the basic concepts of Docker Compose:
- defining services
- configuring network interaction
- mounting volumes
- managing running containers

## Prerequisites

- Installed Docker Engine
- Installed Docker Compose
- Basic command line skills

## Exercise 1: Creating and Running a Simple Application

### Step 1: Explore the Project Structure

The project directory already has the following files prepared:
- `docker-compose.yml` - configuration for Docker Compose
- `web/` - directory with files for the web server
  - `index.html` - simple demonstration page
  - `Dockerfile` - for creating a web server image

### Step 2: Examine the docker-compose.yml File

Open the `docker-compose.yml` file and familiarize yourself with its contents. It describes two services:
- `web` - Nginx-based service that will serve static content
- `db` - Redis service that will be used as a database

### Step 3: Launch the Application

```bash
# Start services in the background
docker-compose up -d
```

### Step 4: Check the Application

```bash
# Verify that containers are running
docker-compose ps

# Open http://localhost:80 in your browser to access the web service
```

### Step 5: View Logs

```bash
# View logs for all services
docker-compose logs

# View logs for the web server only
docker-compose logs web
```

### Step 6: Stop the Application

```bash
# Stop and remove containers
docker-compose down
```

## Exercise 2: Modification and Restart

### Task:
1. Change the content of the `web/index.html` file
2. Change the port on which the web service is available (in the `docker-compose.yml` file)
3. Restart the services and check the changes

```bash
# Restart services with modified configuration
docker-compose up -d

# Verify that the changes have taken effect
# Open http://localhost:<new_port> in your browser
```

## Exercise 3: Interacting with the Database

### Task:
1. Connect to the Redis container
2. Add test data
3. Verify that the data is saved

```bash
# Connect to the Redis container
docker-compose exec db redis-cli

# Inside redis-cli add test data
SET testkey "Hello from Redis!"
GET testkey

# Exit redis-cli
exit
```

## Bonus Task

Modify the `docker-compose.yml` to:
1. Add persistent storage for Redis through a volume
2. Add environment variables for Redis configuration
3. Add a third service - for example, phpMyAdmin or another tool for working with Redis (such as RedisInsight)

## Completion

Upon completion, don't forget to stop and remove the containers:

```bash
docker-compose down
```

## Understanding Check

After completing the exercises, answer the following questions:
1. What are the advantages of using Docker Compose compared to running individual containers manually?
2. How does Docker Compose provide network interaction between containers?
3. What types of volumes can be used in Docker Compose and what are they needed for? 