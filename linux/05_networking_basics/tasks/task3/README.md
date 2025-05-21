# Задача 3: Мониторинг Сетевого Трафика

## Описание
В этом задании вы научитесь анализировать сетевой трафик с помощью различных инструментов, включая tcpdump и wireshark, а также познакомитесь с основами сетевой безопасности.

### Подготовка
Скрипт `setup.sh` создаст тестовое окружение, генерирующее различные типы сетевого трафика для анализа.

### Задачи
1. Базовый анализ трафика:
   - Запустите `tcpdump` для просмотра сетевого трафика
   - Отфильтруйте пакеты по протоколу (TCP/UDP)
   - Сохраните дамп трафика в файл для дальнейшего анализа

2. Анализ HTTP-трафика:
   - Отследите HTTP-запросы к тестовому веб-серверу
   - Проанализируйте заголовки HTTP-пакетов
   - Определите типы HTTP-методов в запросах

3. Фильтрация трафика:
   - Создайте фильтры для определенных IP-адресов
   - Отфильтруйте трафик по портам
   - Найдите пакеты с определенными флагами TCP

4. Анализ производительности:
   - Измерьте объем трафика
   - Определите наиболее активные соединения
   - Проанализируйте задержки в сети

### Ожидаемые результаты
- Понимание структуры сетевых пакетов
- Умение использовать инструменты анализа трафика
- Навыки фильтрации и анализа сетевых данных
- Опыт работы с сетевой безопасностью

### Очистка
После выполнения задания запустите скрипт `cleanup.sh` для остановки генерации трафика и удаления временных файлов.

---

# Task 3: Network Traffic Monitoring

## Description
In this task, you will learn to analyze network traffic using various tools, including tcpdump and wireshark, and get familiar with basic network security concepts.

### Preparation
The `setup.sh` script will create a test environment generating various types of network traffic for analysis.

### Tasks
1. Basic traffic analysis:
   - Run `tcpdump` to view network traffic
   - Filter packets by protocol (TCP/UDP)
   - Save traffic dump to a file for further analysis

2. HTTP traffic analysis:
   - Monitor HTTP requests to the test web server
   - Analyze HTTP packet headers
   - Identify HTTP methods in requests

3. Traffic filtering:
   - Create filters for specific IP addresses
   - Filter traffic by ports
   - Find packets with specific TCP flags

4. Performance analysis:
   - Measure traffic volume
   - Identify most active connections
   - Analyze network latency

### Expected Outcomes
- Understanding network packet structure
- Ability to use traffic analysis tools
- Skills in filtering and analyzing network data
- Experience with network security

### Cleanup
After completing the task, run the `cleanup.sh` script to stop traffic generation and remove temporary files. 