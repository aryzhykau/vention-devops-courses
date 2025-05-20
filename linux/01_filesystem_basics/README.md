# Модуль Linux: Задание 1 - Основы Работы с Файловой Системой

**Цель:** Познакомиться с базовыми командами для навигации и управления файлами и директориями в операционной системе Linux.

## Задание

Выполните следующие шаги в терминале Linux:

1.  **Навигация:**
    *   Определите текущую директорию.
    *   Перейдите в корневую директорию (`/`).
    *   Перейдите в вашу домашнюю директорию (~).
    *   Создайте новую директорию `my_test_dir` в вашей домашней директории.
    *   Перейдите в созданную директорию `my_test_dir` используя относительный путь.
    *   Определите текущую директорию еще раз, чтобы убедиться, что вы находитесь в `my_test_dir`.
    *   Перейдите обратно в вашу домашнюю директорию, используя `..`.
    *   Перейдите в директорию `/usr/bin`, используя абсолютный путь.
    *   Перейдите обратно в `my_test_dir` используя абсолютный или относительный путь.

2.  **Работа с файлами и директориями:**
    *   Находясь в `my_test_dir`, создайте пустой файл с именем `my_file.txt`.
    *   Создайте вложенную директорию `sub_dir` внутри `my_test_dir`.
    *   Создайте еще один файл `another_file.txt` внутри `sub_dir`.
    *   Скопируйте файл `my_file.txt` из `my_test_dir` в `sub_dir`. Убедитесь, что он появился в `sub_dir`.
    *   Переименуйте скопированный файл в `sub_file_copy.txt` внутри `sub_dir`.
    *   Переместите файл `another_file.txt` из `sub_dir` обратно в `my_test_dir`.
    *   Удалите директорию `sub_dir` **вместе со всем ее содержимым**.
    *   Удалите файл `my_file.txt`.

3.  **Просмотр содержимого файлов (практика):**
    *   Создайте новый файл `sample.txt` и добавьте в него несколько строк текста (можно использовать `echo` или текстовый редактор вроде `nano`).
    *   Просмотрите все содержимое файла `sample.txt`.
    *   Просмотрите только первые 2 строки файла `sample.txt`.
    *   Просмотрите только последние 3 строки файла `sample.txt`.
    *   Просмотрите содержимое файла постранично (если файл достаточно большой, можно скопировать в него много текста).

4.  **Поиск файлов:**
    *   Находясь в вашей домашней директории, найдите файл `sample.txt` по имени, начиная поиск из текущей директории.
    *   Найдите все файлы с расширением `.txt` в вашей домашней директории и всех поддиректориях.
    *   Используйте команду `locate` для поиска файла `sample.txt` (если база данных locate обновлена).

## Ожидаемый Результат

После выполнения всех шагов директория `my_test_dir` должна быть пуста (или удалена, если вы удаляли ее в конце), а файл `sample.txt` должен остаться, если вы не удалили его в процессе экспериментов. Главное – это успешное выполнение каждой команды и понимание ее работы.

---

# Linux Module: Assignment 1 - Filesystem Basics

**Objective:** Familiarize yourself with basic commands for navigating and managing files and directories in the Linux operating system.

## Assignment

Perform the following steps in your Linux terminal:

1.  **Navigation:**
    *   Identify the current directory.
    *   Change directory to the root directory (`/`).
    *   Change directory to your home directory (~).
    *   Create a new directory named `my_test_dir` in your home directory.
    *   Change directory into the newly created `my_test_dir` using a relative path.
    *   Identify the current directory again to confirm you are in `my_test_dir`.
    *   Navigate back to your home directory using `..`.
    *   Change directory to `/usr/bin` using an absolute path.
    *   Navigate back to `my_test_dir` using an absolute or relative path.

2.  **File and Directory Manipulation:**
    *   While in `my_test_dir`, create an empty file named `my_file.txt`.
    *   Create a nested directory `sub_dir` inside `my_test_dir`.
    *   Create another file `another_file.txt` inside `sub_dir`.
    *   Copy the file `my_file.txt` from `my_test_dir` to `sub_dir`. Verify it appeared in `sub_dir`.
    *   Rename the copied file in `sub_dir` to `sub_file_copy.txt`.
    *   Move the file `another_file.txt` from `sub_dir` back to `my_test_dir`.
    *   Remove the directory `sub_dir` **along with all its contents**.
    *   Remove the file `my_file.txt`.

3.  **Viewing File Content (Practice):**
    *   Create a new file `sample.txt` and add several lines of text to it (you can use `echo` or a text editor like `nano`).
    *   View the entire content of `sample.txt`.
    *   View only the first 2 lines of `sample.txt`.
    *   View only the last 3 lines of `sample.txt`.
    *   View the file content page by page (if the file is large enough, you can copy a lot of text into it).

4.  **Searching for Files:**
    *   While in your home directory, find the file `sample.txt` by name, starting the search from the current directory.
    *   Find all files with the `.txt` extension in your home directory and all subdirectories.
    *   Use the `locate` command to search for `sample.txt` (if the locate database is updated).

## Expected Outcome

After completing all steps, the `my_test_dir` directory should be empty (or removed if you deleted it at the end), and the `sample.txt` file should remain unless you deleted it during your experiments. The main goal is the successful execution of each command and understanding its operation. 