# Задание 2.1: Базовые Права Доступа и Владение

**Цель:** Понять основы прав доступа к файлам и директориям в Linux и научиться управлять ими.

**Описание:** В этом задании вы познакомитесь с концепцией прав доступа (чтение, запись, выполнение) для владельца, группы и остальных пользователей. Вы научитесь просматривать текущие права, изменять их с помощью команды `chmod` и менять владельца/группу с помощью команды `chown`.

**Задачи:**

1.  Создайте новый файл и директорию в своей рабочей директории.
2.  Просмотрите права доступа для созданных файла и директории с помощью команды `ls -l`.
3.  Измените права доступа к файлу так, чтобы только владелец мог его читать и записывать.
4.  Измените права доступа к директории так, чтобы владелец имел полные права, группа могла только читать и выполнять, а остальные не имели никаких прав.
5.  Используйте октальную нотацию для установки прав доступа к другому файлу или директории.
6.  Создайте нового пользователя и группу (если возможно в вашей среде тестирования, например, Docker).
7.  Измените владельца и группу созданного файла на нового пользователя и группу соответственно.
8.  Проверьте, как права доступа влияют на возможность выполнения различных операций (чтение, запись, выполнение, вход в директорию) от имени разных пользователей.

## Задание

Выполните следующие шаги в терминале Linux. Вы можете работать в своей домашней директории или создать временную папку для экспериментов.

1.  **Создание и просмотр:**
    *   Создайте пустой файл с именем `my_file.txt`.
    *   Создайте новую директорию с именем `my_directory`.
    *   Просмотрите детальную информацию о созданных файле и директории, используя команду `ls -l`.
    *   Объясните для себя (можно записать в комментарии в вашей ветке или в отдельный файл): что означают первый символ в строке прав (`-` или `d`), следующие три группы символов (`rwx`), а также имя владельца и группы.

2.  **Изменение прав доступа (chmod):**
    *   Измените права на файл `my_file.txt` так, чтобы **только владелец** имел права на чтение (`r`) и запись (`w`), а у группы и остальных не было никаких прав. Проверьте результат с помощью `ls -l`.
        *   Попробуйте использовать символический режим (`chmod u=rw,g=,o= файл`).
        *   Попробуйте использовать восьмеричный режим (`chmod 600 файл`).
    *   Измените права на директорию `my_directory` так, чтобы **только владелец** имел полные права (`rwx`), а у группы и остальных не было никаких прав. Проверьте результат (`chmod 700 директория`).
    *   Измените права на файл `my_file.txt` так, чтобы:
        *   Владелец: чтение, запись, выполнение (`rwx`)
        *   Группа: чтение, выполнение (`r-x`)
        *   Остальные: только чтение (`r--`)
        *   Сделайте это сначала в символическом виде (`chmod u=rwx,g=rx,o=r файл`). Проверьте результат.
        *   Затем повторите изменение, используя восьмеричный режим. Определите соответствующее восьмеричное число (подсказка: r=4, w=2, x=1) и примените `chmod`. Проверьте результат.

3.  **Изменение владельца и группы (chown, chgrp):**
    *   (Для выполнения этого шага вам могут понадобиться права суперпользователя `sudo`). Создайте нового тестового пользователя (например, `testuser`) и новую тестовую группу (например, `testgroup`). Используйте команды `useradd` и `groupadd`.
    *   Измените владельца файла `my_file.txt` на `testuser` с помощью команды `chown`.
    *   Измените группу директории `my_directory` на `testgroup` с помощью команды `chgrp`.
    *   Попробуйте изменить владельца и группу файла `my_file.txt` одновременно на `testuser:testgroup` с помощью одной команды `chown`.
    *   Проверьте измененные права и владение с помощью `ls -l`.
    *   (Очистка): После выполнения задания вы можете удалить созданного тестового пользователя (`userdel testuser`) и группу (`groupdel testgroup`), а также созданные файлы и директории (`rm -rf my_file.txt my_directory`). Вам понадобятся права `sudo`.

## Ожидаемый Результат

К концу выполнения задания вы должны уметь просматривать и интерпретировать строки прав доступа в `ls -l`, уверенно использовать команды `chmod` (как в символическом, так и в восьмеричном режиме), `chown` и `chgrp` для изменения прав и владения. Вы также должны понимать, какие права необходимы для выполнения различных операций с файлами и директориями.

---

# Linux Module: Assignment 2.1 - Basic Permissions and Ownership

**Objective:** Learn the concept of permissions and ownership in Linux, and how to view and modify them using the `ls`, `chmod`, `chown`, and `chgrp` commands.

**Description:** In this assignment, you will learn the basics of file and directory permissions in Linux and how to manage them.

**Tasks:**

1.  Create a new file and directory in your working directory.
2.  View the permissions of the created file and directory using the `ls -l` command.
3.  Change the permissions of the file so that only the owner can read and write it.
4.  Change the permissions of the directory so that the owner has full permissions, the group can only read and execute, and others have no permissions.
5.  Use octal notation to set permissions for another file or directory.
6.  Create a new user and group (if possible in your testing environment, such as Docker).
7.  Change the owner and group of the created file to the new user and group respectively.
8.  Check how permissions affect the ability to perform different operations (reading, writing, executing, entering the directory) from different users.

## Assignment

Perform the following steps in your Linux terminal. You can work in your home directory or create a temporary folder for experimentation.

1.  **Creation and Viewing:**
    *   Create an empty file named `my_file.txt`.
    *   Create a new directory named `my_directory`.
    *   View detailed information about the created file and directory using the `ls -l` command.
    *   Explain to yourself (you can write it down in comments in your branch or in a separate file): what do the first character in the permissions string (`-` or `d`), the next three groups of characters (`rwx`), and the owner and group names signify.

2.  **Changing Permissions (chmod):**
    *   Change the permissions of `my_file.txt` so that **only the owner** has read (`r`) and write (`w`) permissions, and the group and others have no permissions. Verify the result with `ls -l`.
        *   Try using symbolic mode (`chmod u=rw,g=,o= file`).
        *   Try using octal mode (`chmod 600 file`).
    *   Change the permissions of `my_directory` so that **only the owner** has full permissions (`rwx`), and the group and others have no permissions. Verify the result (`chmod 700 directory`).
    *   Change the permissions of `my_file.txt` so that:
        *   Owner: read, write, execute (`rwx`)
        *   Group: read, execute (`r-x`)
        *   Others: read only (`r--`)
        *   Do this first in symbolic mode (`chmod u=rwx,g=rx,o=r file`). Verify the result.
        *   Then repeat the change using octal mode. Determine the corresponding octal number (hint: r=4, w=2, x=1) and apply `chmod`. Verify the result.

3.  **Changing Ownership and Group (chown, chgrp):**
    *   (You may need superuser privileges `sudo` to perform this step). Create a new test user (e.g., `testuser`) and a new test group (e.g., `testgroup`). Use the `useradd` and `groupadd` commands.
    *   Change the owner of `my_file.txt` to `testuser` using the `chown` command.
    *   Change the group of `my_directory` to `testgroup` using the `chgrp` command.
    *   Try changing both the owner and group of `my_file.txt` simultaneously to `testuser:testgroup` using a single `chown` command.
    *   Проверьте измененные права и владение с помощью `ls -l`.
    *   (Очистка): После выполнения задания вы можете удалить созданного тестового пользователя (`userdel testuser`) и группу (`groupdel testgroup`), а также созданные файлы и директории (`rm -rf my_file.txt my_directory`). Вам понадобятся права `sudo`.

## Expected Outcome

By the end of this assignment, you should be able to view and interpret permission strings in `ls -l`, confidently use the `chmod` (both symbolic and octal modes), `chown`, and `chgrp` commands to change permissions and ownership. You should also understand which permissions are necessary to perform different operations on files and directories. 