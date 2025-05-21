# Модуль Linux: Задание 1.2 - Траблшутинг Nginx

**Цель:** Практиковать навыки навигации по файловой системе, поиска файлов и диагностики проблем, исследуя неработающую конфигурацию Nginx.

## Сценарий Проблемы

Представьте, что вы работаете на сервере, где установлен Nginx. После недавних изменений сервис Nginx перестал запускаться. Ваша задача - найти причину неисправности и устранить ее, используя доступные системные утилиты, команды навигации и поиска, а также логи.

## Задание

1.  **Подготовка:**
    *   Убедитесь, что у вас есть доступ к терминалу сервера с установленным Nginx (или установите Nginx локально).
    *   Перейдите в директорию `linux/01_filesystem_basics/troubleshooting_nginx`.
    *   Выполните `sudo ./setup.sh`, который находится в этой же директории. **ВНИМАНИЕ:** Этот скрипт внесет изменения в системные файлы (установит Nginx, если его нет, изменит конфигурацию). Убедитесь, что вы понимаете, что делает скрипт, прежде чем его запускать, и запускайте его в подходящем окружении (виртуальная машина, контейнер).
    *   После запуска `sudo ./setup.sh`, попробуйте проверить статус сервиса Nginx (`systemctl status nginx`) и убедитесь, что он не запущен и показывает ошибку.

2.  **Диагностика и Поиск:**
    *   Используйте команды навигации (`cd`, `pwd`, `ls`) для перемещения по файловой системе и осмотра содержимого директорий.
    *   Используйте команды для просмотра логов системы (`journalctl`) и специфичных логов Nginx (обычно в `/var/log/nginx/`), чтобы найти причину ошибки запуска. Логи часто указывают на проблемный файл и строку.
    *   Исследуйте конфигурационные файлы Nginx (основной `/etc/nginx/nginx.conf` и включенные файлы). Обратите внимание на строки, которые могут включать другие файлы.
    *   Используйте команды поиска (`find`, `grep`) для обнаружения измененных или новых файлов конфигурации Nginx в неочевидных местах файловой системы.

3.  **Устранение Проблемы:**
    *   Найдите файл(ы) с некорректной конфигурацией, используя информацию из логов и результаты поиска.
    *   Исправьте синтаксическую или логическую ошибку в конфигурационном файле.
    *   Проверьте синтаксис конфигурации Nginx командой `nginx -t`. Эта команда очень полезна для быстрой проверки.
    *   Перезапустите сервис Nginx (`systemctl restart nginx`).
    *   Убедитесь, что сервис успешно запущен (`systemctl status nginx`).

## Ожидаемый Результат

Сервис Nginx успешно запускается после устранения проблемы в конфигурации. Вы должны четко понимать, какой файл стал причиной проблемы, где он находился и как вы это определили.

---

# Linux Module: Assignment 1.2 - Nginx Troubleshooting

**Objective:** Practice filesystem navigation, file searching, and problem diagnosis skills by investigating a non-running Nginx configuration.

## Problem Scenario

Imagine you are working on a server where Nginx is installed. After recent changes, the Nginx service failed to start. Your task is to find the cause of the problem and fix it using available system utilities, navigation and search commands, and logs.

## Assignment

1.  **Preparation:**
    *   Ensure you have access to a server terminal with Nginx installed (or install Nginx locally).
    *   Navigate to the `linux/01_filesystem_basics/troubleshooting_nginx` directory.
    *   Execute the `sudo ./setup.sh` script located in this directory. **ATTENTION:** This script will make changes to system files (install Nginx if not present, modify configuration). Make sure you understand what the script does before running it, and run it in an appropriate environment (virtual machine, container).
    *   After running `sudo ./setup.sh`, try checking the Nginx service status (`systemctl status nginx`) and confirm it is not running and shows an error.

2.  **Diagnosis and Searching:**
    *   Use navigation commands (`cd`, `pwd`, `ls`) to move around the filesystem and inspect directory contents.
    *   Use commands to view system logs (`journalctl`) and Nginx-specific logs (usually in `/var/log/nginx/`) to find the cause of the startup error. Logs often point to the problematic file and line.
    *   Examine Nginx configuration files (the main `/etc/nginx/nginx.conf` and included files). Pay attention to lines that might include other files.
    *   Use search commands (`find`, `grep`) to locate modified or new Nginx configuration files in non-obvious locations on the filesystem.

3.  **Troubleshooting:**
    *   Find the file(s) with the incorrect configuration using information from logs and search results.
    *   Correct the syntax or logical error in the configuration file.
    *   Check the Nginx configuration syntax using the `nginx -t` command. This command is very useful for quick checks.
    *   Restart the Nginx service (`systemctl restart nginx`).
    *   Verify that the service is successfully running (`systemctl status nginx`).

## Expected Outcome

The Nginx service starts successfully after fixing the configuration problem. You should clearly understand which file caused the issue, where it was located, and how you identified it. 
