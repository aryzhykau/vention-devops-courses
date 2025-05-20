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

---

# Troubleshooting Scenarios

## Scenario 1: High CPU Usage

To simulate a high CPU usage scenario, you can run the following command:

```bash
cd linux/04_process_management/troubleshooting/scenario1
chmod +x setup.sh
./setup.sh
```

This command will start a process that consumes a lot of CPU, allowing you to observe the behavior of `ps`, `top`, and `htop`.

## Scenario 2: "Stuck" Process

To simulate a "stuck" process, you can run the following command:

```bash
cd linux/04_process_management/troubleshooting/scenario2
chmod +x setup.sh
./setup.sh
```

This command will start a process that appears to be stuck, allowing you to observe the behavior of `ps`, `top`, and `htop`.

## Scenario 3: Unknown Background Jobs

To simulate unknown background jobs, you can run the following commands:

```bash
cd linux/04_process_management/troubleshooting/scenario3
chmod +x setup.sh
./setup.sh
```

This command will start multiple background jobs, allowing you to observe the behavior of `ps`, `top`, and `htop`.

---

# Cleanup

To stop the simulated processes after completing the assignment, you can run the following commands:

```bash
cd linux/04_process_management/troubleshooting/scenario1
./cleanup.sh

cd linux/04_process_management/troubleshooting/scenario2
./cleanup.sh

cd linux/04_process_management/troubleshooting/scenario3
./cleanup.sh
```

---

# Сценарии Траблшутинга

## Сценарий 1: Высокая Загрузка CPU

Для симуляции сценария высокой загрузки CPU, вы можете выполнить следующую команду:

```bash
cd linux/04_process_management/troubleshooting/scenario1
chmod +x setup.sh
./setup.sh
```

Эта команда запустит процесс, который потребляет значительные ресурсы CPU, позволяя вам наблюдать поведение команд `ps`, `top` и `htop`.

## Сценарий 2: "Зависший" Процесс

Для симуляции "зависшего" процесса, вы можете выполнить следующую команду:

```bash
cd linux/04_process_management/troubleshooting/scenario2
chmod +x setup.sh
./setup.sh
```

Эта команда запустит процесс, который будет казаться зависшим, позволяя вам наблюдать поведение команд `ps`, `top` и `htop`.

## Сценарий 3: Неизвестные Фоновые Задачи

Для симуляции неизвестных фоновых задач, вы можете выполнить следующие команды:

```bash
cd linux/04_process_management/troubleshooting/scenario3
chmod +x setup.sh
./setup.sh
```

Эта команда запустит несколько фоновых задач, позволяя вам наблюдать поведение команд `ps`, `top` и `htop`.

---

# Очистка

Чтобы остановить симулированные процессы после выполнения задания, вы можете выполнить следующие команды:

```bash
cd linux/04_process_management/troubleshooting/scenario1
./cleanup.sh

cd linux/04_process_management/troubleshooting/scenario2
./cleanup.sh

cd linux/04_process_management/troubleshooting/scenario3
./cleanup.sh 