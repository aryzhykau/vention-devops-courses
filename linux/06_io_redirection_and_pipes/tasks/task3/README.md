# Задача 3: Продвинутые Техники Ввода/Вывода

## Описание
В этом задании вы изучите продвинутые техники работы с вводом/выводом в Linux, включая именованные каналы (named pipes), процессные подстановки (process substitution) и here-документы.

### Подготовка
Скрипт `setup.sh` создаст тестовое окружение для практики продвинутых техник ввода/вывода.

### Задачи
1. Именованные каналы (named pipes):
   - Создайте именованный канал с помощью `mkfifo`
   - Настройте передачу данных между процессами через канал
   - Реализуйте простой чат между двумя терминалами

2. Процессные подстановки:
   - Используйте `<(command)` для сравнения выводов команд
   - Примените `>(command)` для обработки вывода на лету
   - Объедините несколько потоков данных

3. Here-документы и here-строки:
   - Используйте here-документ для создания скрипта
   - Примените here-строки для передачи данных командам
   - Создайте конфигурационный файл с помощью here-документа

4. Продвинутые техники:
   - Используйте `exec` для перенаправления ввода/вывода
   - Работайте с несколькими файловыми дескрипторами
   - Создайте конвейер с обработкой ошибок

### Ожидаемые результаты
- Понимание продвинутых концепций ввода/вывода
- Умение работать с именованными каналами
- Навыки использования процессных подстановок
- Опыт применения here-документов и here-строк

### Очистка
После выполнения задания запустите скрипт `cleanup.sh` для удаления тестовых файлов и каналов.

---

# Task 3: Advanced I/O Techniques

## Description
In this task, you will learn advanced I/O techniques in Linux, including named pipes, process substitution, and here-documents.

### Preparation
The `setup.sh` script will create a test environment for practicing advanced I/O techniques.

### Tasks
1. Named pipes:
   - Create a named pipe using `mkfifo`
   - Set up data transfer between processes through the pipe
   - Implement a simple chat between two terminals

2. Process substitution:
   - Use `<(command)` to compare command outputs
   - Apply `>(command)` for on-the-fly output processing
   - Combine multiple data streams

3. Here-documents and here-strings:
   - Use here-document to create a script
   - Apply here-strings to pass data to commands
   - Create a configuration file using here-document

4. Advanced techniques:
   - Use `exec` for I/O redirection
   - Work with multiple file descriptors
   - Create a pipeline with error handling

### Expected Outcomes
- Understanding of advanced I/O concepts
- Ability to work with named pipes
- Skills in using process substitution
- Experience with here-documents and here-strings

### Cleanup
After completing the task, run the `cleanup.sh` script to remove test files and pipes. 