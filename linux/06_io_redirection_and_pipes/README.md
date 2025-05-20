# Задание 6: Перенаправление Ввода/Вывода и Конвейеры

В этом задании вы научитесь эффективно использовать механизмы перенаправления ввода/вывода и конвейеров в командной строке Linux для комбинирования команд и обработки данных.

## Цель Задания

Понять концепции стандартного ввода, стандартного вывода и стандартного потока ошибок, освоить операторы перенаправления (`>`, `>>`, `<`, `2>`, `&>`) и научиться строить конвейеры (`|`) для последовательной обработки данных несколькими командами.

## Задачи

1.  **Перенаправление Стандартного Вывода:**
    *   Перенаправьте стандартный вывод команды (`ls -l`) в файл.
    *   Добавьте стандартный вывод команды (`date`) в конец существующего файла.
    *   Перенаправьте стандартный вывод и стандартный поток ошибок команды в один файл.
2.  **Перенаправление Стандартного Ввода:**
    *   Используйте перенаправление стандартного ввода (`<`) для подачи содержимого файла на вход команде (например, `sort`).
3.  **Использование Конвейеров (Pipes):**
    *   Используйте конвейер (`|`) для передачи стандартного вывода одной команды на стандартный ввод другой.
    *   Постройте конвейер из нескольких команд для фильтрации и обработки текста (например, `cat file.txt | grep "pattern" | sort | uniq`).
    *   Используйте комбинацию перенаправления и конвейеров.

---

# Assignment 6: I/O Redirection and Pipes

In this assignment, you will learn to effectively use I/O redirection and piping mechanisms in the Linux command line to combine commands and process data.

## Assignment Goal

Understand the concepts of standard input, standard output, and standard error, master redirection operators (`>`, `>>`, `<`, `2>`, `&>`), and learn to build pipes (`|`) for sequential data processing by multiple commands.

## Tasks

1.  **Standard Output Redirection:**
    *   Redirect the standard output of a command (`ls -l`) to a file.
    *   Append the standard output of a command (`date`) to an existing file.
    *   Redirect both standard output and standard error of a command to a single file.
2.  **Standard Input Redirection:**
    *   Use standard input redirection (`<`) to feed the content of a file as input to a command (e.g., `sort`).
3.  **Using Pipes:**
    *   Use a pipe (`|`) to send the standard output of one command to the standard input of another.
    *   Build a pipeline of several commands to filter and process text (e.g., `cat file.txt | grep "pattern" | sort | uniq`).
    *   Use a combination of redirection and pipes. 