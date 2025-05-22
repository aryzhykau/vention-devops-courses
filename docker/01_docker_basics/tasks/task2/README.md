# Задача 2: Запуск Первого Контейнера

## Описание
В этом задании вы научитесь работать с базовыми командами Docker для запуска контейнеров, изучите параметры запуска и научитесь взаимодействовать с контейнерами.

### Задачи
1. Работа с образами:
   - Загрузить образ nginx с Docker Hub
   - Просмотреть список локальных образов
   - Изучить информацию об образе

2. Запуск контейнера:
   - Запустить контейнер nginx в фоновом режиме
   - Пробросить порт 80 контейнера на порт 8080 хоста
   - Проверить доступность веб-сервера

3. Взаимодействие с контейнером:
   - Просмотреть логи контейнера
   - Подключиться к контейнеру в интерактивном режиме
   - Изменить страницу приветствия nginx

4. Управление контейнером:
   - Остановить контейнер
   - Запустить контейнер снова
   - Проверить статус контейнера

### Ожидаемые результаты
- Образ nginx успешно загружен
- Контейнер запущен и доступен через порт 8080
- Выполнено подключение к контейнеру
- Измененная страница приветствия отображается
- Освоены базовые команды управления контейнером

### Проверка
Запустите скрипт `check.sh` для проверки корректности выполнения задания:
```bash
./check.sh
```

---

# Task 2: Running Your First Container

## Description
In this task, you will learn to work with basic Docker commands for running containers, study launch parameters, and learn to interact with containers.

### Tasks
1. Working with images:
   - Pull nginx image from Docker Hub
   - View list of local images
   - Study image information

2. Container launch:
   - Run nginx container in background mode
   - Map container port 80 to host port 8080
   - Verify web server accessibility

3. Container interaction:
   - View container logs
   - Connect to container in interactive mode
   - Modify nginx welcome page

4. Container management:
   - Stop the container
   - Start the container again
   - Check container status

### Expected Results
- Nginx image successfully pulled
- Container running and accessible via port 8080
- Successfully connected to container
- Modified welcome page is displayed
- Mastered basic container management commands

### Verification
Run the `check.sh` script to verify the task completion:
```bash
./check.sh
``` 