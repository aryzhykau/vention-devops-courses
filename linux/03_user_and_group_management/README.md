# Задание 3: Управление Пользователями и Группами

В этом задании вы научитесь основам управления пользователями и группами в операционных системах на базе Linux.

## Цель Задания

Понять принципы работы с пользователями и группами, научиться создавать, изменять и удалять их, а также управлять членством пользователей в группах с использованием стандартных утилит командной строки.

## Задачи

1.  **Создание Пользователей и Групп:**
    *   Создайте нового пользователя с домашней директорией и стандартной оболочкой.
    *   Создайте новую группу.
2.  **Изменение Пользователей и Групп:**
    *   Измените комментарий для существующего пользователя.
    *   Измените имя существующей группы.
3.  **Управление Членством в Группах:**
    *   Добавьте созданного пользователя во вновь созданную группу в качестве дополнительной группы.
    *   Проверьте членство пользователя в группах.
4.  **Удаление Пользователей и Групп:**
    *   Удалите созданного пользователя, сохранив его домашнюю директорию.
    *   Удалите созданную группу.

---

# Assignment 3: User and Group Management

In this assignment, you will learn the basics of managing users and groups in Linux-based operating systems.

## Assignment Goal

Understand the principles of working with users and groups, learn how to create, modify, and delete them, and manage user membership in groups using standard command-line utilities.

## Tasks

1.  **Creating Users and Groups:**
    *   Create a new user with a home directory and a standard shell.
    *   Create a new group.
2.  **Modifying Users and Groups:**
    *   Change the comment field for an existing user.
    *   Change the name of an existing group.
3.  **Managing Group Membership:**
    *   Add the created user to the newly created group as a supplementary group.
    *   Verify the user's group membership.
4.  **Deleting Users and Groups:**
    *   Delete the created user, keeping their home directory.
    *   Delete the created group.

## Задание

Выполните следующие шаги в терминале Linux с правами суперпользователя (`sudo`).

1.  **Создание пользователя:**
    *   Создайте нового пользователя с именем `devops_student`. Убедитесь, что для него автоматически создается домашняя директория (обычно `/home/devops_student`). Используйте команду `useradd`.
    *   Установите пароль для пользователя `devops_student` командой `passwd devops_student`. Придумайте простой пароль для целей тестирования.
    *   Проверьте создание пользователя, просмотрев последнюю строку файла `/etc/passwd` (`tail /etc/passwd`) или используя команду `id devops_student`.

2.  **Создание группы:**
    *   Создайте новую группу с именем `course_participants`. Используйте команду `groupadd`.
    *   Проверьте создание группы, просмотрев последнюю строку файла `/etc/group` (`tail /etc/group`) или используя команду `getent group course_participants`.

3.  **Добавление пользователя в группу:**
    *   Добавьте пользователя `devops_student` в группу `course_participants` в качестве **дополнительной** группы. Используйте команду `usermod`. (Подсказка: используйте опцию `-aG` или `-G`).
    *   Проверьте членство пользователя в группах с помощью команды `id devops_student` или `groups devops_student`. Убедитесь, что `course_participants` присутствует в списке его групп.

4.  **Создание пользователя без домашней директории и без UID:**
    *   Создайте второго пользователя с именем `guest_user`, но без создания домашней директории и без автоматического назначения UID (система сама назначит свободный UID, но не резервируйте конкретный). Используйте команду `useradd` с соответствующими опциями.
    *   Проверьте создание пользователя и отсутствие домашней директории, просмотрев `/etc/passwd`.

5.  **Изменение имени пользователя:**
    *   Измените имя пользователя `devops_student` на `student_devops`. Используйте команду `usermod -l`.
    *   Проверьте изменение, просмотрев `/etc/passwd` и используя команду `id student_devops`. Убедитесь, что UID остался прежним.

6.  **Изменение основной группы пользователя:**
    *   Создайте еще одну группу, например, `temporary_group`.
    *   Измените **основную** группу пользователя `guest_user` на `temporary_group`. Используйте команду `usermod -g`.
    *   Проверьте изменение с помощью команды `id guest_user`.

7.  **Добавление пользователя в несколько групп:**
    *   Добавьте пользователя `student_devops` в группу `temporary_group` в качестве дополнительной группы, не удаляя его из других групп (`course_participants`).
    *   Проверьте членство в группах командой `id student_devops` или `groups student_devops`.

8.  **Удаление пользователя (сохраняя домашнюю директорию):**
    *   Удалите пользователя `guest_user`, но оставьте его домашнюю директорию (если она была создана в процессе экспериментов). Используйте команду `userdel` без опции `-r`.
    *   Проверьте, что пользователя больше нет в `/etc/passwd`, но его домашняя директория (если существует) не удалена.

9.  **Удаление пользователя (включая домашнюю директорию):**
    *   Удалите пользователя `student_devops` вместе с его домашней директорией и файлами почты. Используйте команду `userdel -r`.
    *   Проверьте, что пользователя больше нет в `/etc/passwd` и его домашняя директория удалена.

10. **Удаление групп:**
    *   Удалите группы `course_participants` и `temporary_group`. Используйте команду `groupdel`.
    *   Проверьте, что группы удалены, просмотрев `/etc/group`.

## Assignment Steps

Perform the following steps in your Linux terminal with superuser privileges (`sudo`).

1.  **Creating a User:**
    *   Create a new user named `devops_student`. Ensure a home directory is automatically created (usually `/home/devops_student`). Use the `useradd` command.
    *   Set a password for the `devops_student` user using the `passwd devops_student` command. Choose a simple password for testing purposes.
    *   Verify the user creation by viewing the last line of the `/etc/passwd` file (`tail /etc/passwd`) or using the `id devops_student` command.

2.  **Creating a Group:**
    *   Create a new group named `course_participants`. Use the `groupadd` command.
    *   Verify the group creation by viewing the last line of the `/etc/group` file (`tail /etc/group`) or using the `getent group course_participants` command.

3.  **Adding a User to a Group:**
    *   Add the `devops_student` user to the `course_participants` group as a **supplementary** group. Use the `usermod` command. (Hint: use the `-aG` or `-G` option).
    *   Verify the user's group membership using the `id devops_student` or `groups devops_student` command. Ensure `course_participants` is in their group list.

4.  **Creating a User without a Home Directory and without a specified UID:**
    *   Create a second user named `guest_user`, but without creating a home directory and without specifying a UID (the system will assign a free UID, but don't reserve a specific one). Use the `useradd` command with appropriate options.
    *   Verify the user creation and lack of a home directory by viewing `/etc/passwd`.

5.  **Changing a Username:**
    *   Change the username `devops_student` to `student_devops`. Use the `usermod -l` command.
    *   Verify the change by viewing `/etc/passwd` and using the `id student_devops` command. Ensure the UID remains the same.

6.  **Changing a User's Primary Group:**
    *   Create another group, for example, `temporary_group`.
    *   Change the **primary** group of the `guest_user` user to `temporary_group`. Use the `usermod -g` command.
    *   Verify the change using the `id guest_user` command.

7.  **Adding a User to Multiple Groups:**
    *   Add the `student_devops` user to the `temporary_group` group as a supplementary group, without removing them from other groups (`course_participants`).
    *   Verify group membership using the `id student_devops` or `groups student_devops` command.

8.  **Deleting a User (keeping the home directory):**
    *   Delete the `guest_user` user, but keep their home directory (if one was created during your experiments). Use the `userdel` command without the `-r` option.
    *   Verify that the user is no longer in `/etc/passwd`, but their home directory (if it exists) is not deleted.

9.  **Deleting a User (including the home directory):**
    *   Delete the `student_devops` user along with their home directory and mail spool. Use the `userdel -r` command.
    *   Verify that the user is no longer in `/etc/passwd` and their home directory is deleted.

10. **Deleting Groups:**
    *   Delete the `course_participants` and `temporary_group` groups. Use the `groupdel` command.
    *   Verify that the groups are deleted by viewing `/etc/group`.

## Expected Outcome

By the end of this assignment, you should be able to confidently use the `useradd`, `usermod`, `userdel`, `groupadd`, `groupmod`, `groupdel`, `passwd`, `id`, `groups` commands to manage users and groups in Linux. You should understand the difference between a primary and supplementary group and how commands affect home directories and other files associated with the user. 