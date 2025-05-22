# Задача 3: Работа с Контейнерами

## Описание
В этом задании вы научитесь управлять жизненным циклом контейнеров, работать с данными и сетями в Docker, а также освоите основные команды для отладки контейнеров.

### Задачи
1. Управление жизненным циклом:
   - Создать контейнер с именем
   - Запустить контейнер с автоматическим удалением
   - Настроить политику перезапуска контейнера
   - Ограничить ресурсы контейнера (CPU, память)

2. Работа с данными:
   - Создать и подключить том (volume)
   - Смонтировать локальную директорию в контейнер
   - Скопировать файлы между контейнером и хостом
   - Создать и использовать Docker volume

3. Работа с сетью:
   - Создать пользовательскую сеть
   - Подключить контейнер к сети
   - Проверить связность между контейнерами
   - Настроить DNS для контейнеров

4. Отладка контейнеров:
   - Просмотреть логи контейнера
   - Получить информацию о процессах
   - Проверить использование ресурсов
   - Исследовать метаданные контейнера

### Ожидаемые результаты
- Освоены команды управления контейнерами
- Настроена работа с данными и томами
- Создана и настроена сеть для контейнеров
- Освоены инструменты отладки контейнеров

### Проверка
Запустите скрипт `check.sh` для проверки корректности выполнения задания:
```bash
./check.sh
```

---

# Task 3: Working with Containers

## Description
In this task, you will learn to manage container lifecycle, work with data and networks in Docker, and master basic container debugging commands.

### Tasks
1. Lifecycle management:
   - Create a named container
   - Run container with auto-removal
   - Configure container restart policy
   - Limit container resources (CPU, memory)

2. Working with data:
   - Create and attach a volume
   - Mount local directory into container
   - Copy files between container and host
   - Create and use Docker volume

3. Networking:
   - Create custom network
   - Connect container to network
   - Test container connectivity
   - Configure DNS for containers

4. Container debugging:
   - View container logs
   - Get process information
   - Check resource usage
   - Inspect container metadata

### Expected Results
- Mastered container management commands
- Configured data and volume handling
- Created and configured container network
- Learned container debugging tools

### Verification
Run the `check.sh` script to verify the task completion:
```bash
./check.sh
``` 