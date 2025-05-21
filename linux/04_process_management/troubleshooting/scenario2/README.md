# Сценарий 2: "Зависший" Процесс

## Описание
В этом сценарии симулируется ситуация с "зависшим" процессом, который запускается в фоновом режиме и не завершается самостоятельно. Такие ситуации часто возникают при работе с долгими операциями или при сбоях в работе программ.

### Задача
1. Запустите скрипт `setup.sh`
2. Используя команду `jobs`, найдите запущенный фоновый процесс
3. С помощью команды `ps` определите PID процесса
4. Попробуйте перевести процесс на передний план с помощью `fg`
5. Верните процесс в фоновый режим с помощью `Ctrl+Z` и `bg`
6. Завершите процесс используя `kill`

### Ожидаемый результат
- Научиться работать с фоновыми процессами
- Освоить переключение процессов между фоновым и передним планом
- Получить практику в идентификации и завершении "зависших" процессов

---

# Scenario 2: "Stuck" Process

## Description
This scenario simulates a situation with a "stuck" process that runs in the background and doesn't terminate on its own. Such situations often occur when dealing with long operations or program malfunctions.

### Task
1. Run the `setup.sh` script
2. Using the `jobs` command, find the running background process
3. Use the `ps` command to determine the process PID
4. Try to bring the process to the foreground using `fg`
5. Return the process to background using `Ctrl+Z` and `bg`
6. Terminate the process using `kill`

### Expected Outcome
- Learn to work with background processes
- Master switching processes between background and foreground
- Gain practice in identifying and terminating "stuck" processes 