#!/bin/bash

# Создание пользователя appuser
useradd appuser

# Создание директории и файла конфигурации
mkdir /etc/my_service
touch /etc/my_service/service.conf

# Установка некорректных прав и владения
chown root:root /etc/my_service/service.conf
chmod 600 /etc/my_service/service.conf
chown root:root /etc/my_service
chmod 700 /etc/my_service

echo "Среда для Сценария 1 настроена. Пользователь appuser не сможет прочитать /etc/my_service/service.conf" 