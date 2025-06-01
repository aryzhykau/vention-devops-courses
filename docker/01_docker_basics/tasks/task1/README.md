# Задача 1: Установка Docker

## Описание
В этом задании вы научитесь устанавливать Docker на Linux-систему, настраивать его и проверять корректность установки.

### Задачи
1. Подготовка системы:
   - Удалить старые версии Docker (если есть)
   - Обновить списки пакетов
   - Установить необходимые зависимости

2. Установка Docker:
   - Добавить официальный репозиторий Docker
   - Установить последнюю версию Docker Engine
   - Установить Docker Compose

3. Настройка пользователя:
   - Добавить текущего пользователя в группу docker
   - Применить изменения групп без перезагрузки

4. Проверка установки:
   - Запустить службу Docker
   - Проверить статус службы
   - Выполнить тестовый запуск контейнера hello-world

### Ожидаемые результаты
- Docker Engine успешно установлен
- Docker Compose установлен
- Служба Docker запущена и работает
- Пользователь может запускать Docker без sudo
- Тестовый контейнер успешно запущен

### Проверка
Запустите скрипт `check.sh` для проверки корректности выполнения задания:
```bash
./check.sh
```

---

# Task 1: Docker Installation

## Description
In this task, you will learn how to install Docker on a Linux system, configure it, and verify the installation.

### Tasks
1. System preparation:
   - Remove old Docker versions (if any)
   - Update package lists
   - Install required dependencies

2. Docker installation:
   - Add official Docker repository
   - Install latest Docker Engine
   - Install Docker Compose

3. User configuration:
   - Add current user to docker group
   - Apply group changes without reboot

4. Installation verification:
   - Start Docker service
   - Check service status
   - Run test hello-world container

### Expected Results
- Docker Engine successfully installed
- Docker Compose installed
- Docker service running and active
- User can run Docker without sudo
- Test container successfully launched

### Verification
Run the `check.sh` script to verify the task completion:
```bash
./check.sh
``` 