# Docker Compose

Docker Compose - это инструмент для определения и запуска многоконтейнерных приложений Docker. С помощью файла YAML вы настраиваете сервисы приложения, а затем создаете и запускаете все сервисы из этой конфигурации одной командой.

## Содержание раздела

1. **01_compose_basics** - Основы Docker Compose
   - Создание простого docker-compose.yml
   - Запуск и остановка сервисов
   - Базовые команды

2. **02_compose_network** - Сетевое взаимодействие
   - Связывание сервисов
   - Настройка DNS между контейнерами
   - Проброс портов

3. **03_compose_volumes** - Работа с данными
   - Постоянное хранение данных
   - Совместное использование файлов
   - Резервное копирование данных

4. **04_compose_scale** - Масштабирование сервисов
   - Запуск нескольких экземпляров сервиса
   - Балансировка нагрузки
   - Ограничение ресурсов

5. **05_real_world_app** - Практическое приложение
   - Полноценное многокомпонентное приложение
   - Управление зависимостями между сервисами
   - Конфигурирование через переменные окружения

## Ключевые концепции

- **Сервисы** - определяют, какие контейнеры должны быть запущены
- **Сети** - правила сетевого взаимодействия между контейнерами
- **Тома** - место, где хранятся постоянные данные
- **Зависимости** - порядок запуска контейнеров и их взаимосвязи
- **Переменные окружения** - конфигурация контейнеров через переменные

## Базовые команды

```bash
# Запуск сервисов
docker-compose up

# Запуск в фоновом режиме
docker-compose up -d

# Остановка сервисов
docker-compose down

# Просмотр логов
docker-compose logs

# Запуск команды в контейнере
docker-compose exec <service_name> <command>

# Просмотр запущенных контейнеров
docker-compose ps
```

---

# Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. Using a YAML file, you configure your application's services, then create and start all the services from your configuration with a single command.

## Section Content

1. **01_compose_basics** - Docker Compose Basics
   - Creating a simple docker-compose.yml
   - Starting and stopping services
   - Basic commands

2. **02_compose_network** - Network Interaction
   - Connecting services
   - DNS settings between containers
   - Port forwarding

3. **03_compose_volumes** - Working with Data
   - Persistent data storage
   - File sharing
   - Data backups

4. **04_compose_scale** - Service Scaling
   - Running multiple instances of a service
   - Load balancing
   - Resource limitations

5. **05_real_world_app** - Practical Application
   - Full multi-component application
   - Managing dependencies between services
   - Configuration via environment variables

## Key Concepts

- **Services** - define which containers should be run
- **Networks** - rules for network interaction between containers
- **Volumes** - where persistent data is stored
- **Dependencies** - order of container startup and their relationships
- **Environment Variables** - container configuration through variables

## Basic Commands

```bash
# Start services
docker-compose up

# Start in background mode
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs

# Run a command in a container
docker-compose exec <service_name> <command>

# View running containers
docker-compose ps
``` 