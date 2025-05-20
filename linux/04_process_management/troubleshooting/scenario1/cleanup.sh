#!/bin/bash

# Сценарий 1: Очистка (Высокая загрузка CPU)
# Завершает процесс, запущенный setup.sh в этой директории.

echo "Попытка завершить процесс высокой загрузки CPU..."

pkill -f "linux/04_process_management/troubleshooting/scenario1/setup.sh"

echo "Процесс завершен, если он был запущен." 