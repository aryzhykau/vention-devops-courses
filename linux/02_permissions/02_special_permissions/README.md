# Задание 2.2: Специальные Права Доступа (SUID, SGID, Sticky Bit)

**Цель:** Изучить и понять назначение и использование специальных прав доступа: SUID, SGID и Sticky Bit.

**Описание:** Помимо стандартных прав (чтение, запись, выполнение) для владельца, группы и остальных, существуют специальные права, которые влияют на поведение файлов и директорий. В этом задании вы узнаете, как эти права работают, как их просматривать и изменять, и в каких сценариях они используются.

**Задачи:**

1.  **SUID (Set User ID):**
    *   Найдите в вашей системе примеры файлов с установленным SUID битом (например, `/usr/bin/passwd`).
    *   Объясните, почему SUID установлен на `/usr/bin/passwd` и как это влияет на выполнение команды.
    *   Создайте исполняемый скрипт или программу, установите SUID бит и продемонстрируйте его эффект (требуются права суперпользователя).
    *   Обсудите риски безопасности, связанные с SUID.

2.  **SGID (Set Group ID):**
    *   Найдите в вашей системе примеры директорий с установленным SGID битом.
    *   Создайте директорию, установите SGID бит и создайте в ней несколько файлов. Проверьте, какая группа назначается новым файлам.
    *   Обсудите типичные сценарии использования SGID для управления доступом к общим ресурсам.

3.  **Sticky Bit:**
    *   Найдите примеры директорий с установленным Sticky Bit (например, `/tmp`).
    *   Объясните назначение Sticky Bit для директорий.
    *   Создайте директорию, установите Sticky Bit и проверьте его поведение, пытаясь удалить файлы, принадлежащие другим пользователям (требуется симуляция работы нескольких пользователей).

4.  **Практика и Комбинации:**
    *   Потренируйтесь устанавливать и снимать специальные права, используя символьную и октальную нотацию (`chmod`).
    *   Попробуйте установить несколько специальных битов одновременно и проанализируйте результат `ls -l`.

**Ожидаемый результат:** Документация (в формате markdown или текстовом файле) с ответами на поставленные вопросы, примерами команд и описанием проделанных экспериментов.

---

# Assignment 2.2: Special Permissions (SUID, SGID, Sticky Bit)

**Objective:** Study and understand the purpose and use of special permissions: SUID, SGID, and Sticky Bit.

**Description:** In addition to standard permissions (read, write, execute) for the owner, group, and others, there are special permissions that affect the behavior of files and directories. In this assignment, you will learn how these permissions work, how to view and change them, and in which scenarios they are used.

**Tasks:**

1.  **SUID (Set User ID):**
    *   Find examples of files with the SUID bit set on your system (e.g., `/usr/bin/passwd`).
    *   Explain why SUID is set on `/usr/bin/passwd` and how it affects command execution.
    *   Create an executable script or program, set the SUID bit, and demonstrate its effect (requires superuser privileges).
    *   Discuss the security risks associated with SUID.

2.  **SGID (Set Group ID):**
    *   Find examples of directories with the SGID bit set on your system.
    *   Create a directory, set the SGID bit, and create several files within it. Check which group is assigned to the new files.
    *   Discuss typical use cases for SGID to manage access to shared resources.

3.  **Sticky Bit:**
    *   Find examples of directories with the Sticky Bit set (e.g., `/tmp`).
    *   Explain the purpose of the Sticky Bit for directories.
    *   Create a directory, set the Sticky Bit, and test its behavior by trying to delete files owned by other users (requires simulating multiple users).

4.  **Practice and Combinations:**
    *   Practice setting and removing special permissions using symbolic and octal notation (`chmod`).
    *   Try setting multiple special bits simultaneously and analyze the result of `ls -l`.

**Expected Outcome:** Documentation (in markdown format or a text file) with answers to the questions, command examples, and descriptions of the experiments performed. 