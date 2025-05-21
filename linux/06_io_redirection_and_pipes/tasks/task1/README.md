# Задача 1: Основы Перенаправления Ввода/Вывода

## Описание
В этом задании вы научитесь базовым принципам перенаправления ввода/вывода в Linux, включая работу со стандартными потоками (stdin, stdout, stderr) и файловыми дескрипторами.

### Подготовка
Скрипт `setup.sh` создаст тестовое окружение с различными типами файлов и данных для практики перенаправления.

### Задачи
1. Перенаправление вывода (stdout):
   - Перенаправьте вывод команды `ls -l` в файл
   - Добавьте результат другой команды в конец того же файла (>>)
   - Проверьте содержимое получившегося файла

2. Работа с потоком ошибок (stderr):
   - Создайте команду, генерирующую ошибки
   - Перенаправьте поток ошибок в отдельный файл
   - Перенаправьте оба потока (stdout и stderr) в разные файлы
   - Объедините оба потока в один файл

3. Перенаправление ввода (stdin):
   - Используйте файл в качестве входных данных для команды
   - Создайте файл с списком слов и отсортируйте его
   - Используйте here-document (<<) для создания файла

4. Работа с дескрипторами:
   - Создайте новый файловый дескриптор
   - Выполните запись в файл через дескриптор
   - Закройте дескриптор после использования

### Ожидаемые результаты
- Понимание концепции потоков ввода/вывода в Linux
- Умение перенаправлять stdout и stderr
- Навыки работы с файловыми дескрипторами
- Опыт использования различных операторов перенаправления

### Очистка
После выполнения задания запустите скрипт `cleanup.sh` для удаления тестовых файлов и возврата системы в исходное состояние.

---

# Task 1: Basics of I/O Redirection

## Description
In this task, you will learn the basic principles of I/O redirection in Linux, including working with standard streams (stdin, stdout, stderr) and file descriptors.

### Preparation
The `setup.sh` script will create a test environment with various types of files and data for redirection practice.

### Tasks
1. Output redirection (stdout):
   - Redirect `ls -l` command output to a file
   - Append another command's output to the same file (>>)
   - Check the contents of the resulting file

2. Working with error stream (stderr):
   - Create a command that generates errors
   - Redirect error stream to a separate file
   - Redirect both streams (stdout and stderr) to different files
   - Combine both streams into one file

3. Input redirection (stdin):
   - Use a file as input for a command
   - Create a file with a list of words and sort it
   - Use here-document (<<) to create a file

4. Working with descriptors:
   - Create a new file descriptor
   - Write to a file through the descriptor
   - Close the descriptor after use

### Expected Outcomes
- Understanding of I/O streams concept in Linux
- Ability to redirect stdout and stderr
- Skills in working with file descriptors
- Experience with various redirection operators

### Cleanup
After completing the task, run the `cleanup.sh` script to remove test files and return the system to its original state. 