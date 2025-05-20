#!/bin/bash

# Создание группы appgroup
groupadd appgroup

# Создание директории и файла логов
mkdir /var/log/my_app
touch /var/log/my_app/app.log

# Установка некорректных прав и владения
chown root:root /var/log/my_app/app.log
chmod 644 /var/log/my_app/app.log
chown root:appgroup /var/log/my_app
chmod 755 /var/log/my_app

echo "Среда для Сценария 2 настроена. Группа appgroup не сможет писать в /var/log/my_app/app.log" 