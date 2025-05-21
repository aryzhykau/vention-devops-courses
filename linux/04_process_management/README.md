# Задание 4: Работа с Процессами

В этом задании вы научитесь просматривать запущенные процессы, управлять ими, а также запускать команды в фоне и на переднем плане в операционных системах на базе Linux.

## Цель Задания

Понять жизненный цикл процессов, научиться использовать различные утилиты для мониторинга и управления процессами, а также освоить методы управления выполнением команд в фоновом и переднем режиме.

## Задачи

1.  **Просмотр Процессов:**
    *   Используйте команды `ps`, `top` (или `htop`, если доступно) для просмотра списка запущенных процессов.
    *   Найдите информацию о конкретном процессе по его имени или PID.
    *   Отфильтруйте вывод команд `ps` для отображения процессов конкретного пользователя или с определенным статусом.
2.  **Управление Процессами:**
    *   Запустите простую команду (например, `sleep 60`) и найдите ее PID.
    *   Завершите процесс, используя команду `kill` с его PID.
    *   Используйте команды `killall` или `pkill` для завершения процессов по их имени.
3.  **Управление Выполнением Команд:**
    *   Запустите команду в фоновом режиме (`&`).
    *   Используйте команду `jobs` для просмотра фоновых задач.
    *   Переместите фоновую задачу на передний план (`fg`).
    *   Переместите задачу с переднего плана в фоновый режим (`Ctrl+Z` и `bg`).

---

# Assignment 4: Working with Processes

In this assignment, you will learn how to view running processes, manage them, and run commands in the background and foreground in Linux-based operating systems.

## Assignment Goal

Understand the process lifecycle, learn to use various utilities for monitoring and managing processes, and master methods for controlling command execution in background and foreground modes.

## Tasks

1.  **Viewing Processes:**
    *   Use the `ps`, `top` (or `htop` if available) commands to list running processes.
    *   Find information about a specific process by its name or PID.
    *   Filter the output of `ps` commands to display processes for a specific user or with a particular status.
2.  **Managing Processes:**
    *   Start a simple command (e.g., `sleep 60`) and find its PID.
    *   Terminate the process using the `kill` command with its PID.
    *   Use the `killall` or `pkill` commands to terminate processes by their name.
3.  **Managing Command Execution:**
    *   Run a command in the background (`&`).
    *   Use the `jobs` command to view background jobs.
    *   Bring a background job to the foreground (`fg`).
    *   Move a foreground job to the background (`Ctrl+Z` and `bg`).