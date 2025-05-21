# Задача 1: Базовая Настройка и Диагностика Сети

## Описание
В этом задании вы научитесь базовой настройке сетевых интерфейсов, диагностике сетевых проблем и работе с основными сетевыми утилитами Linux.

### Подготовка
Скрипт `setup.sh` создаст виртуальный сетевой интерфейс и настроит тестовое окружение для практики.

### Задачи
1. Проверьте текущую конфигурацию сети:
   - Используйте `ip addr show` для просмотра сетевых интерфейсов
   - Определите IP-адрес и маску подсети виртуального интерфейса
   - Проверьте таблицу маршрутизации с помощью `ip route`

2. Выполните базовую диагностику:
   - Проверьте доступность локального хоста (127.0.0.1)
   - Выполните ping до созданного виртуального интерфейса
   - Проверьте DNS-резолвинг с помощью `nslookup` или `dig`

3. Настройте сетевой интерфейс:
   - Измените IP-адрес виртуального интерфейса
   - Добавьте дополнительный IP-адрес (alias)
   - Проверьте новую конфигурацию

4. Исследуйте сетевые соединения:
   - Используйте `netstat` или `ss` для просмотра активных соединений
   - Определите какие порты прослушиваются в системе
   - Проанализируйте статистику сетевых интерфейсов

### Ожидаемые результаты
- Понимание базовой структуры сетевых интерфейсов Linux
- Умение использовать основные утилиты диагностики сети
- Навыки настройки сетевых интерфейсов
- Опыт работы с сетевыми соединениями

### Очистка
После выполнения задания запустите скрипт `cleanup.sh` для удаления виртуального интерфейса и возврата системы в исходное состояние.

---

# Task 1: Basic Network Configuration and Diagnostics

## Description
In this task, you will learn basic network interface configuration, network problem diagnostics, and work with essential Linux networking utilities.

### Preparation
The `setup.sh` script will create a virtual network interface and set up a test environment for practice.

### Tasks
1. Check current network configuration:
   - Use `ip addr show` to view network interfaces
   - Determine IP address and subnet mask of the virtual interface
   - Check routing table using `ip route`

2. Perform basic diagnostics:
   - Check localhost availability (127.0.0.1)
   - Ping the created virtual interface
   - Test DNS resolution using `nslookup` or `dig`

3. Configure network interface:
   - Change virtual interface IP address
   - Add additional IP address (alias)
   - Verify new configuration

4. Investigate network connections:
   - Use `netstat` or `ss` to view active connections
   - Determine which ports are being listened on
   - Analyze network interface statistics

### Expected Outcomes
- Understanding of basic Linux network interface structure
- Ability to use basic network diagnostic utilities
- Skills in configuring network interfaces
- Experience with network connections

### Cleanup
After completing the task, run the `cleanup.sh` script to remove the virtual interface and return the system to its original state. 