# Сценарий 3: Множественные Фоновые Задачи

## Описание
В этом сценарии симулируется ситуация с несколькими фоновыми процессами, работающими одновременно. Такая ситуация часто встречается в реальных системах, когда несколько задач выполняются параллельно.

### Задача
1. Запустите скрипт `setup.sh`
2. Используя команду `jobs`, просмотрите список всех фоновых задач
3. С помощью команды `ps` найдите PID каждого процесса
4. Определите, какая задача была запущена первой/последней
5. Попрактикуйтесь в переключении между задачами с помощью `fg %номер_задачи`
6. Завершите все процессы с помощью `killall sleep`

### Ожидаемый результат
- Научиться управлять множественными фоновыми процессами
- Освоить навыки мониторинга нескольких задач
- Получить практику в массовом завершении процессов
- Научиться различать и переключаться между несколькими фоновыми задачами

---

# Scenario 3: Multiple Background Jobs

## Description
This scenario simulates a situation with multiple background processes running simultaneously. Such a situation is common in real systems when several tasks are executed in parallel.

### Task
1. Run the `setup.sh` script
2. Using the `jobs` command, view the list of all background jobs
3. Use the `ps` command to find the PID of each process
4. Determine which job was started first/last
5. Practice switching between jobs using `fg %job_number`
6. Terminate all processes using `killall sleep`

### Expected Outcome
- Learn to manage multiple background processes
- Master skills in monitoring multiple tasks
- Gain practice in mass process termination
- Learn to distinguish and switch between multiple background jobs 