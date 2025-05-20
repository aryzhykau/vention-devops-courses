# Задание 2.3: Траблшутинг Прав Доступа

**Цель:** Научиться диагностировать и устранять проблемы, связанные с некорректными правами доступа к файлам и директориям, используя прилагаемые скрипты для создания проблемных сред.

**Описание:** Неправильно настроенные права доступа являются частой причиной проблем в работе приложений и систем. В этом задании вы будете использовать готовые скрипты для создания различных проблем с правами доступа, а затем диагностировать и устранять их.

**Сценарии для траблшутинга:**

1.  **Сценарий 1: Отказ в доступе к файлу конфигурации.**
    *   Описание: Сервис не может прочитать свой файл конфигурации (`/etc/my_service/service.conf`).
    *   Задача: Используйте скрипт `scenario1/setup.sh` (выполните с `sudo`), чтобы создать проблемную ситуацию. **После выполнения скрипта, пользователь `appuser` не сможет прочитать файл `/etc/my_service/service.conf` (например, при попытке выполнить `sudo -u appuser cat /etc/my_service/service.conf` вы получите ошибку 'Permission denied').** Продиагностируйте проблему (проверьте права на файл и директории) и устраните ее, изменив права доступа так, чтобы `appuser` мог читать файл.

2.  **Сценарий 2: Невозможность записать в лог-файл.**
    *   Описание: Приложение не может записать данные в свой лог-файл (`/var/log/my_app/app.log`).
    *   Задача: Используйте скрипт `scenario2/setup.sh` (выполните с `sudo`), чтобы создать проблемную ситуацию. **После выполнения скрипта, процессы, работающие от имени группы `appgroup`, не смогут писать в файл `/var/log/my_app/app.log` (например, при попытке добавить текст в файл от пользователя, входящего в `appgroup`, вы получите ошибку 'Permission denied').** Продиагностируйте проблему и устраните ее, изменив права доступа так, чтобы группа `appgroup` могла писать в файл.

3.  **Сценарий 3: Исполняемый файл не запускается.**
    *   Описание: Пользователь не может запустить скрипт или исполняемый файл (`/usr/local/bin/my_script.sh`), хотя файл существует.
    *   Задача: Используйте скрипт `scenario3/setup.sh` (выполните с `sudo`), чтобы создать проблемную ситуацию. **После выполнения скрипта, пользователь `testuser2` не сможет выполнить `/usr/local/bin/my_script.sh` (при попытке запуска получите ошибку 'Permission denied').** Продиагностируйте проблему и устраните ее, изменив права доступа так, чтобы `testuser2` мог выполнять файл.

4.  **Сценарий 4: Проблема с доступом к общей директории.**
    *   Описание: Несколько пользователей из одной группы могут удалять файлы друг друга в общей директории (`/shared/data`).
    *   Задача: **Инструкции по настройке, воспроизведению проблемы и решению этого сценария находятся в отдельном файле `scenario4/README.md`.** Используйте скрипт `scenario4/setup.sh` (выполните с `sudo`), чтобы создать проблемную ситуацию. Ознакомьтесь с описанием проблемы и шагами по ее воспроизведению и решению в `scenario4/README.md`, а затем выполните траблшутинг.

**Ожидаемый результат:** К концу выполнения задания вы должны уметь диагностировать и устранять проблемы с правами доступа, созданные с помощью прилагаемых скриптов. Для каждого сценария вы должны быть готовы объяснить:

*   Описание симулируемой проблемы (как ее воспроизвести).
*   Шаги по диагностике проблемы (какие команды использовать и что искать в выводе).
*   Шаги по устранению проблемы (какие команды использовать для исправления прав).
*   Объяснение, почему предложенное решение работает.

---

# Assignment 2.3: Permissions Troubleshooting

**Objective:** Learn to diagnose and resolve issues related to incorrect file and directory permissions using the provided scripts to create problematic environments.

**Description:** Incorrectly configured permissions are a common cause of problems in the operation of applications and systems. In this assignment, you will use ready-made scripts to create various permission issues, and then diagnose and resolve them.

**Troubleshooting Scenarios:**

1.  **Scenario 1: Configuration file access denied.**
    *   Description: A service cannot read its configuration file (`/etc/my_service/service.conf`).
    *   Task: Use the `scenario1/setup.sh` script (run with `sudo`) to create the problematic situation. **After running the script, the user `appuser` will not be able to read the `/etc/my_service/service.conf` file (e.g., attempting to run `sudo -u appuser cat /etc/my_service/service.conf` will result in a 'Permission denied' error).** Diagnose the problem (check file and directory permissions) and fix it by changing the permissions so that `appuser` can read the file.

2.  **Scenario 2: Unable to write to a log file.**
    *   Description: An application cannot write data to its log file (`/var/log/my_app/app.log`).
    *   Task: Use the `scenario2/setup.sh` script (run with `sudo`) to create the problematic situation. **After running the script, processes running as the `appgroup` group will not be able to write to the `/var/log/my_app/app.log` file (e.g., attempting to append text to the file as a user in `appgroup` will result in a 'Permission denied' error).** Diagnose the problem and fix it by changing the permissions so that the `appgroup` group can write to the file.

3.  **Scenario 3: Executable file will not run.**
    *   Description: A user cannot execute a script or executable file (`/usr/local/bin/my_script.sh`), although the file exists.
    *   Task: Use the `scenario3/setup.sh` script (run with `sudo`) to create the problematic situation. **After running the script, the user `testuser2` will not be able to execute `/usr/local/bin/my_script.sh` (attempting to run will result in a 'Permission denied' error).** Diagnose the problem and fix it by changing the permissions so that `testuser2` can execute the file.

4.  **Scenario 4: Access issue with a shared directory.**
    *   Description: Several users from the same group can delete each other's files in a shared directory (`/shared/data`).
    *   Task: **Instructions for setting up, reproducing, and solving this scenario are in the separate file `scenario4/README.md`.** Use the `scenario4/setup.sh` script (run with `sudo`) to create the problematic situation. Refer to the problem description and steps for reproduction and solution in `scenario4/README.md`, then perform the troubleshooting.

**Expected Outcome:** By the end of this assignment, you should be able to diagnose and resolve permission issues created using the provided scripts. For each scenario, you should be prepared to explain:

*   Describe the simulated problem (how to reproduce it).
*   Provide steps for diagnosing the problem (what commands to use and what to look for in the output).
*   Provide steps for resolving the problem (what commands to use to fix permissions).
*   Explain why the proposed solution works. 