# Задача 2: Работа с Сетевыми Сервисами

## Описание
В этом задании вы научитесь работать с базовыми сетевыми сервисами в Linux, включая настройку простого веб-сервера и анализ его работы.

### Подготовка
Скрипт `setup.sh` установит и настроит простой веб-сервер Python для практики, а также создаст тестовые файлы.

### Задачи
1. Анализ запущенного веб-сервера:
   - Проверьте, что сервер запущен и прослушивает порт 8080
   - Используйте `curl` для отправки GET-запроса к серверу
   - Проверьте доступ к тестовой странице через браузер

2. Мониторинг соединений:
   - Используйте `netstat` или `ss` для просмотра активных соединений с веб-сервером
   - Отследите новые соединения в реальном времени
   - Проанализируйте состояния TCP-соединений

3. Работа с логами:
   - Найдите и проанализируйте логи веб-сервера
   - Отследите запросы к серверу в реальном времени
   - Определите IP-адреса клиентов

4. Изменение конфигурации:
   - Измените порт веб-сервера
   - Добавьте новый контент
   - Перезапустите сервер и проверьте изменения

### Ожидаемые результаты
- Понимание принципов работы веб-сервера
- Умение анализировать сетевые соединения
- Навыки работы с системными логами
- Опыт настройки сетевых служб

### Очистка
После выполнения задания запустите скрипт `cleanup.sh` для остановки веб-сервера и удаления тестовых файлов.

---

# Task 2: Working with Network Services

## Description
In this task, you will learn to work with basic network services in Linux, including setting up a simple web server and analyzing its operation.

### Preparation
The `setup.sh` script will install and configure a simple Python web server for practice and create test files.

### Tasks
1. Analyze the running web server:
   - Verify that the server is running and listening on port 8080
   - Use `curl` to send GET requests to the server
   - Check access to the test page through a browser

2. Connection monitoring:
   - Use `netstat` or `ss` to view active connections to the web server
   - Track new connections in real-time
   - Analyze TCP connection states

3. Working with logs:
   - Find and analyze web server logs
   - Monitor server requests in real-time
   - Identify client IP addresses

4. Configuration changes:
   - Change the web server port
   - Add new content
   - Restart the server and verify changes

### Expected Outcomes
- Understanding web server operation principles
- Ability to analyze network connections
- Skills in working with system logs
- Experience in configuring network services

### Cleanup
After completing the task, run the `cleanup.sh` script to stop the web server and remove test files. 