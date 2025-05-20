# Задание 5: Основы Работы с Сетью

В этом задании вы познакомитесь с основными утилитами командной строки Linux для диагностики и мониторинга сетевых подключений и конфигурации.

## Цель Задания

Научиться использовать базовые сетевые команды для проверки доступности узлов, определения маршрутов, просмотра сетевых интерфейсов и прослушиваемых портов.

## Задачи

1.  **Проверка Сетевых Подключений:**
    *   Используйте команду `ping` для проверки доступности удаленного узла (например, `google.com`).
    *   Используйте команду `traceroute` для определения маршрута следования пакетов до удаленного узла.
2.  **Просмотр Сетевой Конфигурации:**
    *   Используйте команды `ip addr` (или `ifconfig`, если доступно) для просмотра информации о сетевых интерфейсах системы (IP-адреса, MAC-адреса, состояние интерфейса).
    *   Используйте команду `ip route` для просмотра таблицы маршрутизации по умолчанию и статических маршрутов.
3.  **Проверка Открытых Портов и Соединений:**
    *   Используйте команды `netstat` или `ss` для просмотра списка открытых портов и установленных сетевых соединений.
    *   Отфильтруйте вывод, чтобы найти процессы, прослушивающие определенный порт.

---

# Assignment 5: Networking Basics

In this assignment, you will become familiar with fundamental Linux command-line utilities for diagnosing and monitoring network connections and configuration.

## Assignment Goal

Learn to use basic networking commands to check host reachability, determine routes, view network interfaces, and identify listening ports.

## Tasks

1.  **Checking Network Connectivity:**
    *   Use the `ping` command to check the reachability of a remote host (e.g., `google.com`).
    *   Use the `traceroute` command to determine the path packets take to a remote host.
2.  **Viewing Network Configuration:**
    *   Use the `ip addr` (or `ifconfig` if available) commands to view information about the system's network interfaces (IP addresses, MAC addresses, interface status).
    *   Use the `ip route` command to view the default routing table and static routes.
3.  **Checking Open Ports and Connections:**
    *   Use the `netstat` or `ss` commands to view a list of open ports and established network connections.
    *   Filter the output to find processes listening on a specific port. 